(*

Experimenting with automating the introduction of existentials


1. Difficulties in applying intro_exists:

 {  A  }

    { ?p ?w }
     intro_exists ?w ?p
    { ex ?p }

 { ex ?p * ?f }

 { ... }

This requires solving, since intro_exists is framed:

  A =?=> ?p ?w * ?f

This can't be solved since we have two unknowns on the LHS.

--------------------------------------------------------------------------------
2.

One might consider turning intro_exists into the SteelF effect, so
that we don't add another frame, but that's not what's desired either.

Consider:

  val free (p:ptr) : ST _ (ex (fun v -> p `pts_to` v)) emp


let caller (p q:ptr) : ST _ (p `pts_to` 17 `star` q `pts_to` 18) =
  intro_exists _ _; //if this were not framed
                    //then we would capture both p and q under the exists
                    //and this wouldn't unify with the pre of `free p` anyway
  free p

--------------------------------------------------------------------------------

So, our idea is to enhance the framing tactic directly so that it can
introduce existentials "on the fly" without introducing additional
vprop variables, as in case 1.

i.e. we want to write


let caller (p q:ptr) : ST _ (p `pts_to` 17 `star` q `pts_to` 18) =
  free p;
  ...

And this would generate constraints like so

{  p `pts_to` 17 `star` q `pts_to` 18 }

    { ex (pts_to p) }
      free p
    { emp }

{emp * ?f }


and we would try to solve


p `pts_to` 17 `star` q `pts_to` 18
==>
ex (pts_to p) * ?f

And this has only 1 unknown, so we have some hope of solving for ?f

The basic idea is as follows:

In case the current unification heuristics fail, i.e.,

  1. let LEX = { ex p1, .., ex pn } be all the unique occurrences of
     ex terms on the LHS

  2. let REX = { ex q1, .., ex qm } be all the unique occurrences of
     ex terms on the RLHS

  3. Cancel terms in LEX with terms from REX:

     For each element l in LEX, find a unique element r in REX such
     that l unifies with r.

       - If successful, remove l and r from LEX and REX and repeat

       - If not, fail: there is an exists in LEX that cannot be
         matched in REX.

     Limitation: We are not handling AC rewriting under a quantifier, e.g.,

        ex (fun v -> p * q)  will not match
        ex (fun v -> q * p)

     We could enhance this step, so that rather than finding a unifier
     between l and r, we find instead a double implication, e.g., by
     applying lemma like equiv_exists

     Lemma (forall v. p v <==> q v)
           (ex p <==> ex q)


  4. Now, we may have some remaining terms in REX and for these we aim
     to introduce exists from the remaining terms in L


     1. For each r in REX, open the existential with a fresh
          unification variable for the witness

        This corresponds to an application of the following logical rule
       "backwards" to the goal:

       intro_exists (x:a) (v: a -> vprop)
          : Lemma (v x `can_be_split` (ex v))

     2. unifying what's left in RHS with whatever was not yet cancelled in LHS
*)
module SteelIntroExists
open Steel.Effect.Common
open Steel.ST.Util

[@@solve_can_be_split_lookup; (solve_can_be_split_for exists_)]
let _intro_can_be_split_exists = intro_can_be_split_exists

[@@solve_can_be_split_forall_dep_lookup; (solve_can_be_split_forall_dep_for exists_)]
let _intro_can_be_split_forall_dep_exists = intro_can_be_split_forall_dep_exists

assume
val ptr : Type0

assume
val pts_to (p:ptr) (v:nat) : vprop

assume
val free (p:ptr) : STT unit (exists_ (fun v -> pts_to p v)) (fun _ -> emp)

// assume
// val intro_exists_f (#a:Type) (#opened_invariants:_) (x:a) (p:a -> vprop)
//   : STGhostF unit opened_invariants (p x) (fun _ -> exists_ (fun v -> p v)) (True) (fun _ -> True)


// // [@@expect_failure] //we incorrectly pick a too-specific solution failing to generalize over the witness
// // let free_one_explicit (p q:ptr)
// //   : STT unit
// //     (pts_to p 17)
// //     (fun _ -> emp)
// //  = let _ = intro_exists_f 17 _  in
// //    free p
// //#push-options "--tactic_trace_d 1"

let free_one (p q r:ptr)
  : STT unit
    (pts_to p 17 `star` pts_to q 18 `star` pts_to r 19)
    (fun _ -> pts_to p 17 `star` pts_to r 19)
 = let _ = free q in ()

assume
val free2 (p q:ptr) : STT unit (exists_ (fun v -> pts_to p v) `star`
                                exists_ (fun v -> pts_to q v))
                               (fun _ -> emp)


let free_two (p q r:ptr)
  : STT unit
    (pts_to p 17 `star` pts_to q 18 `star` pts_to r 19)
    (fun _ -> pts_to r 19)
 = free p; free q; ()

assume
val correlate (p q:ptr) : STT unit (exists_ (fun v -> pts_to p v `star` pts_to q v))
                                   (fun _ -> emp)

let free_correlate (p q:ptr)
  : STT unit
    (pts_to q 17 `star` pts_to p 17)
    (fun _ -> emp)
 = correlate p q; ()


let free_correlate_alt (p q:ptr)
  : STT unit
    (pts_to p 17 `star` pts_to q 17)
    (fun _ -> emp)
 = correlate p q; ()

assume
val alloc (n:nat) : STT ptr emp (fun p -> pts_to p n)

let construct () : STT ptr emp (fun p -> exists_ (fun v -> pts_to p v)) =
  let p = alloc 17 in
  p


assume
val pts_to_rev (n:nat) (p:ptr) : vprop

assume
val alloc_rev (n:nat) : STT ptr emp (fun p -> pts_to_rev n p)


let construct_rev () : STT ptr emp (fun p -> exists_ (fun v -> pts_to_rev v p)) =
  let p = alloc_rev 17 in
  p

open Steel.ST.Reference
assume
val increment (#p:_) (#v:_) (x:ref int)
  : STT unit (pts_to x p v)
             (fun _ -> pts_to x p (v + 1))
