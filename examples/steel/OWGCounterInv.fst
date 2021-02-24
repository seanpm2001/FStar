(*
   Copyright 2021 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

(*
 * An implementation of the parallel counter presented by Owicki and Gries
 * "Verifying properties of parallel programs: An axiomatic approach.", CACM'76
 *
 * using disposable invariants
 *
 * See OWGCounter.fst for an implementation using the locks
 *)

module OWGCounterInv

module G = FStar.Ghost

open Steel.Memory
open Steel.FractionalPermission
open Steel.Reference
open Steel.SpinLock

open Steel.Effect.Atomic
open Steel.Effect

module R = Steel.Reference
module P = Steel.FractionalPermission
module A = Steel.Effect.Atomic

open Steel.DisposableInvariant

#set-options "--using_facts_from '* -FStar.Tactics -FStar.Reflection' --fuel 0 --ifuel 0"

let half_perm = half_perm (MkPerm 1.0R)

let fst = fst
let snd = snd

(**** A few wrappers over library functions ****)

(*
 * Wrapper over ghost_gather that rewrites sum_perm half_perm half_perm to full_perm
 *)
let ghost_gather (#uses:inames) (v1 v2:G.erased int) (r:ghost_ref int)
  : SteelAtomic unit uses unobservable
      (ghost_pts_to r half_perm v1 `star`
       ghost_pts_to r half_perm v2)
      (fun _ -> ghost_pts_to r full_perm v1)
      (fun _ -> True)
      (fun _ _ _ -> v1 == v2)
  = ghost_gather#_ #_ #_ #_ #v1 #v2 r;
    change_slprop (ghost_pts_to r (sum_perm half_perm half_perm) v1)
                  (ghost_pts_to r full_perm v1) (fun _ -> ())

(*
 * Similar wrapper over ghost_share that rewrites (half_perm full_perm) to half_perm
 *)
let ghost_share (#uses:inames) (v1 v2:G.erased int) (r:ghost_ref int)
  : SteelAtomic unit uses unobservable
      (ghost_pts_to r full_perm v1)
      (fun _ -> ghost_pts_to r half_perm v1 `star`
             ghost_pts_to r half_perm v2)
      (fun _ -> v1 == v2)
      (fun _ _ _ -> True)
  = ghost_share #_ #_ #_ #v1 r;
    change_slprop (ghost_pts_to r (P.half_perm P.full_perm) v1 `star`
                   ghost_pts_to r (P.half_perm P.full_perm) v1)
                  (ghost_pts_to r half_perm v1 `star`
                   ghost_pts_to r half_perm v2) (fun _ -> ())

(*
 * Perm rewriting wrappers over share and gather invariant
 *)
let share_invariant (#p:slprop) (#uses:inames) (i:inv p)
  : SteelAtomicT unit uses unobservable
      (active full_perm i)
      (fun _ -> active half_perm i `star` active half_perm i)
  = share i;
    change_slprop (active _ i `star`
                   active _ i)
                  _ (fun _ -> ())

let gather_invariant (#p:slprop) (#uses:inames) (i:inv p)
  : SteelAtomicT unit uses unobservable
      (active half_perm i `star` active half_perm i)
      (fun _ -> active full_perm i)
  = gather #_ #half_perm #half_perm #_ i;
    change_slprop (active (sum_perm half_perm half_perm) i)
                  (active full_perm i) (fun _ -> ())

(*
 * A SteelAtomic to Steel lift for with_invariant
 *
 * We will use it when composing with_invariant with Steel.Effect.par
 *)

let with_invariant (#a:Type)
                   (#fp:slprop)
                   (#fp':a -> slprop)
                   (#o:observability)
                   (#p:slprop)
                   (#perm:_)
                   (i:inv p)
                   ($f:unit -> SteelAtomicT a (Set.singleton (name i)) o
                                             (p `star` fp)
                                             (fun x -> p `star` fp' x))
  : SteelT a (active perm i `star` fp) (fun x -> active perm i `star` fp' x)
  = assert (Set.equal (Set.singleton (name i)) (set_add (name i) Set.empty));
    with_invariant i f

(**** Definition of the invariant slprop ****)

(*
 * The invariant holds half permission for the ghost refs and full perm for
 *   the counter, with an assertion relating their contents
 *)

[@@ __reduce__]
let inv_pred (r:ref int) (r1 r2:ghost_ref int) =
  fun (w:G.erased int & G.erased int) ->
    ghost_pts_to r1 half_perm (fst w) `star`
    ghost_pts_to r2 half_perm (snd w) `star`
    pts_to r full_perm (fst w + snd w)

(*
 * The h_exists slprop that the invariant protects
 *)
[@@ __reduce__]
let inv_slprop (r:ref int) (r1 r2:ghost_ref int) : slprop =
  h_exists (inv_pred r r1 r2)

(*
 * A helper lemma to show that in the inv slprop the ghost refs commute with equiv
 *)
#push-options "--warn_error -271"
let inv_equiv_lemma (r:ref int) (r1 r2:ghost_ref int)
  : Lemma (inv_slprop r r1 r2 `equiv` inv_slprop r r2 r1)
          [SMTPat (inv_slprop r r1 r2)]
  = let aux (r:ref int) (r1 r2:ghost_ref int) (m:mem)
      : Lemma
          (requires interp (inv_slprop r r1 r2) m)
          (ensures interp (inv_slprop r r2 r1) m)
          [SMTPat ()]
      = let w : G.erased (G.erased int & G.erased int) = id_elim_exists (inv_pred r r1 r2) m in
        assert ((ghost_pts_to r1 half_perm (snd (snd w, fst w)) `star`
                 ghost_pts_to r2 half_perm (fst (snd w, fst w)) `star`
                 pts_to r full_perm (G.hide (G.reveal (fst (snd w, fst w)) + G.reveal (snd (snd w, fst w))))) `equiv`
                (ghost_pts_to r2 half_perm (fst (snd w, fst w)) `star`
                 ghost_pts_to r1 half_perm (snd (snd w, fst w)) `star`
                 pts_to r full_perm (G.hide (G.reveal (fst (snd w, fst w)) + G.reveal (snd (snd w, fst w)))))) by Steel.Memory.Tactics.canon ();

        intro_h_exists (snd w, fst w) (inv_pred r r2 r1) m in
    ()
#pop-options


(**** Helpers for the counter implementation ****)

(*
 * Allocating a disposable invariant that protects inv_slprop
 *)
let new_inv (#uses:inames) (#v:G.erased int) (r:ref int) (r1 r2:ghost_ref int)
  : SteelAtomicT (inv (inv_slprop r r1 r2)) uses unobservable
      (pts_to r full_perm v  `star`
       ghost_pts_to r1 half_perm 0 `star`
       ghost_pts_to r2 half_perm v)
      (fun i -> active full_perm i)
  = //rewrite the pts_to r in the form expected by inv_slprop
    change_slprop (pts_to r _ _)
                  (pts_to r full_perm (G.hide (G.reveal (fst (G.hide 0, v)) + G.reveal (snd (G.hide 0, v)))))
                  (fun _ -> ());
 
    intro_exists (G.hide 0, v) (inv_pred r r1 r2);
    new_inv (inv_slprop r r1 r2)

let g_incr (n:G.erased int) = G.elift1 (fun (n:int) -> n + 1) n

(*
 * We assume an atomic increment operation for int refs
 *)
assume val incr_atomic (#uses:inames) (#v:G.erased int) (r:ref int)
  : SteelAtomicT unit uses observable
      (pts_to r full_perm v)
      (fun _ -> pts_to r full_perm (g_incr v))

(*
 * Incrementing the ghost contribution ref
 *
 * The caller provides two half permissions,
 *   and we return the same permissions with the incremented contents
 *)
let incr_ghost_contrib (#uses:inames) (#v1 #v2:G.erased int) (r:ghost_ref int)
  : SteelAtomic unit uses unobservable
      (ghost_pts_to r half_perm v1 `star`
       ghost_pts_to r half_perm v2)
      (fun _ -> ghost_pts_to r half_perm (g_incr v1) `star`
             ghost_pts_to r half_perm (g_incr v2))
      (fun _ -> True)
      (fun _ _ _ -> v1 == v2)
  = ghost_gather v1 v2 r;
    ghost_write r (g_incr v1);
    ghost_share (g_incr v1) (g_incr v2) r

(*
 * Another form of the inv_slprop with conditional on the ghost refs
 *)
[@@ __reduce__]
let inv_slprop_conditional (r:ref int) (r_mine r_other:ghost_ref int) (b:bool) =
  inv_slprop r (if b then r_mine else r_other)
               (if b then r_other else r_mine)


(*
 * The function that each thread invokes
 *
 * It increments the counter and the ghost ref r_mine
 *   consuming and restoring inv_slprop_conditional
 *)
let incr_with_inv_slprop
  (r:ref int) (r_mine r_other:ghost_ref int) (n_ghost:G.erased int) (b:bool) (name:_)
  ()
  : SteelAtomicT unit (Set.singleton name) observable
      (inv_slprop_conditional r r_mine r_other b
       `star`
       ghost_pts_to r_mine half_perm n_ghost)
      (fun _ ->
       inv_slprop_conditional r r_mine r_other b
       `star`
       ghost_pts_to r_mine half_perm (g_incr n_ghost))
  = //get inv_slprop in the context
    change_slprop (inv_slprop_conditional _ _ _ _)
                  (inv_slprop _ _ _) (fun _ -> ());
    let w : G.erased (G.erased int & G.erased int) = witness_h_exists () in
    incr_atomic r;
    incr_ghost_contrib #_ #n_ghost #(fst w) r_mine;

    //restore inv_slprop, by first writing r to a form expected by the invariant
    change_slprop (pts_to r full_perm _)
                  (pts_to r full_perm (G.hide (g_incr (fst w) + snd w))) (fun _ -> ());
    intro_exists (g_incr (fst w), snd w) (inv_pred r r_mine r_other);
    change_slprop (inv_slprop _ _ _)
                  (inv_slprop_conditional _ _ _ _) (fun _ -> ())

(*
 * A with_invariant wrapper over incr_with_inv_slprop
 *)
let incr_with_invariant
  (r:ref int) (r_mine r_other:ghost_ref int) (n_ghost:G.erased int) (b:bool)
  (i:inv (inv_slprop_conditional r r_mine r_other b))
  ()
  : SteelT unit
      (active half_perm i `star` ghost_pts_to r_mine half_perm n_ghost)
      (fun _ -> active half_perm i `star` ghost_pts_to r_mine half_perm (g_incr n_ghost))
  = with_invariant i
      (incr_with_inv_slprop r r_mine r_other n_ghost b (name i))


(*
 * The main thread
 *)
let incr_main (#v:G.erased int) (r:ref int)
  : SteelT unit
      (pts_to r full_perm v)
      (fun _ -> pts_to r full_perm (G.hide (G.reveal v + 2)))
  = //allocate the two ghost refs
    let r1 = ghost_alloc 0 in
    let r2 = ghost_alloc v in

    //split their permissions
    ghost_share 0 _ r1;
    ghost_share v _ r2;

    //create the invariant
    let i = new_inv r r1 r2 in

    //split the invariant permission
    share_invariant i;

    //invoke the two threads
    let _ =
      par (incr_with_invariant r r1 r2 0 true i)
          (incr_with_invariant r r2 r1 v false i) in

    //gather back the invariant and dispose it
    gather_invariant i; dispose i;

    let _ = A.witness_h_exists () in

    //drop the ghost refs
    ghost_gather (g_incr 0) _ r1; drop (ghost_pts_to r1 _ _);
    ghost_gather (g_incr v) _ r2; drop (ghost_pts_to r2 _ _);

    change_slprop (pts_to r _ _)
                  (pts_to r full_perm (v + 2)) (fun _ -> ())