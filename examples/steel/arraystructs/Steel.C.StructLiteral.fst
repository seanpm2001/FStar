module Steel.C.StructLiteral

open Steel.Memory
open Steel.Effect
open Steel.Effect.Common
open Steel.Effect.Atomic

open Steel.C.PCM
open Steel.C.Struct
open Steel.C.Typedef
open Steel.C.Ref // for refine
open Steel.C.Connection
open FStar.List.Tot
open FStar.FunctionalExtensionality

let struct_view_types (fields: struct_fields) (field: field_of fields) =
  (get_field fields field).view_type

let struct tag fields = restricted_t (field_of fields) (struct_view_types fields)

let rec mk_struct (tag: string) (fields: struct_fields)
: mk_struct_ty tag fields
= match fields with
  | [(field, td)] -> fun (x:td.view_type) -> on_dom _ (fun field -> x <: struct_view_types fields field)
  | (field, td) :: fields' ->
    fun (x:td.view_type) ->
    let f: map struct_field_view_type fields' `list_fn` struct tag fields' = mk_struct tag fields' in
    let lift_struct (g: struct tag fields'): struct tag fields =
      let h (field': field_of fields): struct_view_types fields field' =
        if field' = field then x else g field'
      in on_dom _ h
    in
    list_fn_map lift_struct f

let struct_get x field = x field

let struct_put x field v = on_dom _ (fun field' -> if field = field' then v else x field')

let struct_get_put x field v = ()

let struct_put_get x field =
  assert (struct_put x field (x `struct_get` field) `feq` x)

let struct_put_put x field v w =
  assert (struct_put (struct_put x field v) field w `feq` struct_put x field w)

let struct_get_put_ne x field1 field2 v = ()

let struct_put_put_ne x field1 v field2 w = 
  assert (
    struct_put (struct_put x field1 v) field2 w `feq`
    struct_put (struct_put x field2 w) field1 v)

(*
define attribute on mk_struct_view_type, etc..

mk_struct_view': fields:list (string * _) ->
  norm [delta_attr ..; delta Fstar.list.map; ..] .. (mk_struct_view_type fields ..)
  (See FStar.Pervasives.fsti)

to translate t

  typedef_t: typedef t = { ... }

to translate struct tag { S s; ... }

  assume val struct (tag: string) (fields: list (string * typedef)): Type
  assume val mk_struct_typedef (tag: string) (fields: list (string * typedef)):
    typedef (struct tag ["s", typedef_S; ..))
  
  typedef_struct_tag: typedef (struct "tag" ["s", typedef_S; ..]) =
     mk_struct_typedef "tag" ["s", typedef_S; ..]

to translate struct loop { struct loop *again; }

// Done (assuming can store pointers in heap)
  carrier: Type0; 
  pcm: pcm carrier; 

view_type = {loop: ref struct_loop_carrier struct_loop_pcm}

mk_view_type
  (carrier: Type0)
  (pcm: pcm carrier)
-> view_type : {loop: ref struct_loop_carrier struct_loop_pcm}

mk_rec_typedef:
  (carrier: Type0)
  (pcm: pcm carrier)
-> t:typedef (mk_view_type carrier pcm) { t.carrier == carrier /\ t.pcm == pcm}

noeq type typedef = { 

// _
  view_type: Type0; 

// Should be fine
  can_view_unit: bool; 
  view: sel_view pcm view_type can_view_unit; 
} 

  typedef_struct_loop_f (recur:typedef)
  : typedef (struct "loop" ["again", ref_typedef recur.carrier recur.pcm])
  = mk_struct_typedef "loop" ["again", ref_typedef recur.carrier recur.pcm]

  typedef_struct_loop
  : typedef (struct "loop"
      ["again",
       ref_typedef
         typedef_struct_loop.carrier
         typedef_struct_loop.pcm])
  = typedef_struct_loop_f typedef_struct_loop

*)

/// TODO Would be nice to have somtehing like this but proofs get tricky

/// struct_put and struct_get are sound w.r.t. a model of structs as n-tuples

(* BEGIN public *)

let rec list_fn_args (dom: list Type) = match dom with
  | [] -> unit
  | d :: dom -> d & list_fn_args dom

let rec list_apply #dom #b (f: dom `list_fn` b) (xs: list_fn_args dom): b = match dom with
  | [] -> f
  | a :: dom ->
    let (x, xs): a & list_fn_args dom = xs in
    let f: a -> dom `list_fn` b = f in
    f x `list_apply` xs

let rec struct_get_model
  (#tag: string) (#fields: struct_fields) 
  (vs: list_fn_args (mk_struct_ty_dom tag fields))
  (field: field_of fields)
: (get_field fields field).view_type
= match fields with
  | [] -> assert false
  | (field', td) :: fields ->
    let (v, vs): td.view_type & list_fn_args (mk_struct_ty_dom tag fields) = vs in
    if field = field' then v else struct_get_model vs field

let rec struct_put_model
  (#tag: string) (#fields: struct_fields) 
  (vs: list_fn_args (mk_struct_ty_dom tag fields))
  (field: field_of fields)
  (v: (get_field fields field).view_type)
: list_fn_args (mk_struct_ty_dom tag fields)
= match fields with
  | [] -> vs
  | (field', td) :: fields ->
    let (v', vs): td.view_type & list_fn_args (mk_struct_ty_dom tag fields) = vs in
    if field = field' then (v, vs) else (v', struct_put_model vs field v)

(* END public *)

val struct_get_sound
  (#tag: string) (#fields: struct_fields) 
  (vs: list_fn_args (mk_struct_ty_dom tag fields))
  (field: field_of fields)
: Lemma (
    (mk_struct tag fields `list_apply` vs) `struct_get` field ==
    struct_get_model vs field)

(*
let rec struct_get_sound #tag #fields vs field : Lemma (ensures
    (mk_struct tag fields `list_apply` vs) `struct_get` field ==
    struct_get_model vs field) (decreases fields) = match fields with
  | [] -> ()
  | (field', td) :: fields ->
    let (v, vs): td.view_type & list_fn_args (mk_struct_ty_dom tag fields) = vs in
    let field: field_of ((field', td) :: fields) = field in
    if field = field' then begin
      let f = mk_struct tag ((field', td) :: fields) in
      assert ((list_apply #(mk_struct_ty_dom tag ((field', td) :: fields)) f (v, vs)) `struct_get` field ==
        begin
          let (x, xs): (struct_field_view_type (field', td) & list_fn_args (mk_struct_ty_dom tag fields)) = (v, vs) in
          let f: struct_field_view_type (field', td) -> (mk_struct_ty_dom tag fields `list_fn` struct tag fields) = admit() in
          f x `list_apply` xs
        end);
      assume ((list_apply #(mk_struct_ty_dom tag ((field', td) :: fields)) (mk_struct tag ((field', td) :: fields)) (v, vs)) `struct_get` field == v)
    end else admit()//struct_get_sound #tag #fields vs field
    *)

let struct_pcm_carrier tag fields = restricted_t (field_of fields) (struct_carriers fields)

let struct_pcm tag fields = prod_pcm (struct_pcms tag fields)

let rec mk_struct_pcm (tag: string) (fields: struct_fields)
: mk_struct_pcm_ty tag fields
= match fields with
  | [(field, td)] -> fun (x:td.carrier) -> on_dom _ (fun field -> x <: struct_carriers fields field)
  | (field, td) :: fields' ->
    fun (x:td.carrier) ->
    let f: map struct_field_carrier fields' `list_fn` struct_pcm_carrier tag fields' = mk_struct_pcm tag fields' in
    let lift_struct (g: struct_pcm_carrier tag fields'): struct_pcm_carrier tag fields =
      let h (field': field_of fields): struct_carriers fields field' =
        if field' = field then x else g field'
      in on_dom _ h
    in
    list_fn_map lift_struct f

let struct_pcm_get x field = x field

let struct_pcm_put x field v = on_dom _ (fun field' -> if field = field' then v else x field')

let struct_pcm_get_put x field v = ()

let struct_pcm_put_get x field =
  assert (struct_pcm_put x field (x `struct_pcm_get` field) `feq` x)

let struct_pcm_put_put x field v w =
  assert (struct_pcm_put (struct_pcm_put x field v) field w `feq` struct_pcm_put x field w)

let struct_pcm_get_put_ne x field1 field2 v = ()

let struct_pcm_put_put_ne x field1 v field2 w =
   assert (
     struct_pcm_put (struct_pcm_put x field1 v) field2 w `feq`
     struct_pcm_put (struct_pcm_put x field2 w) field1 v)

let field_views (tag: string) (fields: struct_fields) (field: field_of fields)
: sel_view (struct_pcms tag fields field) (struct_view_types fields field) false
= (get_field fields field).view

let struct_view_to_view_prop (tag: string) (fields: struct_fields)
: struct_pcm_carrier tag fields -> prop
= fun x -> forall (field:field_of fields). (field_views tag fields field).to_view_prop (x field)

let struct_view_to_view (tag: string) (fields: struct_fields)
: refine (struct_pcm_carrier tag fields) (struct_view_to_view_prop tag fields) ->
  Tot (struct tag fields)
= fun x -> on_dom _ (fun (field: field_of fields) -> (field_views tag fields field).to_view (x field))

let struct_view_to_carrier (tag: string) (fields: struct_fields)
: struct tag fields ->
  Tot (refine (struct_pcm_carrier tag fields) (struct_view_to_view_prop tag fields))
= fun x ->
  let y: struct_pcm_carrier tag fields =
    on_dom _ (fun (field: field_of fields) ->
      (field_views tag fields field).to_carrier (x field)
      <: struct_carriers fields field)
  in y

let struct_view_to_view_frame (tag: string) (fields: struct_fields)
  (x: struct tag fields)
  (frame: struct_pcm_carrier tag fields)
: Lemma
    (requires (composable (struct_pcm tag fields) (struct_view_to_carrier tag fields x) frame))
    (ensures
      struct_view_to_view_prop tag fields
        (op (struct_pcm tag fields) (struct_view_to_carrier tag fields x) frame) /\ 
      struct_view_to_view tag fields
        (op (struct_pcm tag fields) (struct_view_to_carrier tag fields x) frame) == x)
= let p = struct_pcms tag fields in
  let aux (k:field_of fields)
  : Lemma (
      (field_views tag fields k).to_view_prop
        (op (p k) ((field_views tag fields k).to_carrier (x k)) (frame k)) /\
      (field_views tag fields k).to_view
        (op (p k) ((field_views tag fields k).to_carrier (x k)) (frame k)) == x k)
  = assert (composable (p k) ((field_views tag fields k).to_carrier (x k)) (frame k));
    (field_views tag fields k).to_view_frame (x k) (frame k)
  in FStar.Classical.forall_intro aux;
  assert (
    struct_view_to_view tag fields
       (op (prod_pcm p) (struct_view_to_carrier tag fields x) frame) `feq` x)

let struct_view_to_carrier_not_one (tag: string) (fields: struct_fields)
: squash (
    ~ (exists x. struct_view_to_carrier tag fields x == one (struct_pcm tag fields)) /\
    ~ (struct_view_to_view_prop tag fields (one (struct_pcm tag fields))))
= let (field, _) :: _ = fields in
  let field: field_of fields = field in
  (field_views tag fields field).to_carrier_not_one

let struct_view tag fields = {
  to_view_prop = struct_view_to_view_prop tag fields;
  to_view = struct_view_to_view tag fields;
  to_carrier = struct_view_to_carrier tag fields;
  to_carrier_not_one = struct_view_to_carrier_not_one tag fields;
  to_view_frame = struct_view_to_view_frame tag fields;
}

let struct_field tag fields field = struct_field (struct_pcms tag fields) field

/// TODO move and dedup with Steel.C.Ptr.fst

let vpure_sel'
  (p: prop)
: Tot (selector' (squash p) (Steel.Memory.pure p))
= fun (m: Steel.Memory.hmem (Steel.Memory.pure p)) -> pure_interp p m

let vpure_sel
  (p: prop)
: Tot (selector (squash p) (Steel.Memory.pure p))
= vpure_sel' p

[@@ __steel_reduce__]
let vpure'
  (p: prop)
: GTot vprop'
= {
  hp = Steel.Memory.pure p;
  t = squash p;
  sel = vpure_sel p;
}

[@@ __steel_reduce__]
let vpure (p: prop) : Tot vprop = VUnit (vpure' p)

let intro_vpure
  (#opened: _)
  (p: prop)
: SteelGhost unit opened
    emp
    (fun _ -> vpure p)
    (fun _ -> p)
    (fun _ _ h' -> p)
=
  change_slprop_rel
    emp
    (vpure p)
    (fun _ _ -> p)
    (fun m -> pure_interp p m)

let elim_vpure
  (#opened: _)
  (p: prop)
: SteelGhost unit opened
    (vpure p)
    (fun _ -> emp)
    (fun _ -> True)
    (fun _ _ _ -> p)
=
  change_slprop_rel
    (vpure p)
    emp
    (fun _ _ -> p)
    (fun m -> pure_interp p m; reveal_emp (); intro_emp m)

assume val pts_to_v
  (#pcm: pcm 'b) (#can_view_unit: bool)
  (p: ref 'a pcm) (view: sel_view pcm 'c can_view_unit)
  (v: 'c)
: vprop
//= (p `pts_to_view` view) `vdep` (fun x -> vpure (x == v))

assume val struct_get'
  (#tag: string) (#fields: struct_fields)
  (x: struct tag fields) (field: field_of fields)
: (get_field fields field).view_type

assume val struct_field':
  tag: string -> fields: struct_fields -> field: field_of fields
    -> Prims.Tot
      (connection #(struct_pcm_carrier tag fields)
          #(struct_carriers fields field)
          (struct_pcm tag fields)
          (struct_pcms tag fields field))

[@@__reduce__]
let pts_to_field
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
  (s: struct tag fields)
  (field: field_of fields)
: vprop
= pts_to_v
    (ref_focus p (struct_field' tag fields field))
    (struct_views fields field)
    (s `struct_get'` field)

[@@__reduce__]
let rec pts_to_fields'
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
  (s: struct tag fields)
  (fields': struct_fields)
: vprop
= match fields' with
  | [(field, _)] ->
    if has_field_bool fields field then pts_to_field tag fields p s field else emp
  | (field, _) :: fields' ->
    if has_field_bool fields field then begin
      pts_to_field tag fields p s field `star`
      pts_to_fields' tag fields p s fields'
    end else emp

[@@__reduce__]
let pts_to_fields
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
  (s: struct tag fields)
: vprop
= pts_to_fields' tag fields p s fields

assume val explode (#opened: inames)
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
  (s: Ghost.erased (struct tag fields))
: SteelGhostT unit opened
    (pts_to_v p (struct_view tag fields) s)
    (fun _ -> pts_to_fields tag fields p s)

assume val recombine (#opened: inames)
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
  (s: Ghost.erased (struct tag fields))
: SteelGhostT unit opened
    (pts_to_fields tag fields p s)
    (fun _ -> pts_to_v p (struct_view tag fields) s)

/// Point struct

open Steel.C.Opt

[@@__reduce__]
let c_int: typedef = {
  carrier = option int;
  pcm = opt_pcm #int;
  view_type = int;
  view = opt_view int;
}

[@@__reduce__]
let point_fields: struct_fields = [
  "x", c_int;
  "y", c_int;
]

//[@@iter_unfold]
[@@__reduce__]
let point = struct "point" point_fields

//[@@iter_unfold]
[@@__reduce__]
let point_pcm_carrier = struct_pcm_carrier "point" point_fields
//[@@iter_unfold]
[@@__reduce__]
let point_pcm: pcm point_pcm_carrier = struct_pcm "point" point_fields

/// (mk_point x y) represents (struct point){.x = x, .y = y}
/// (mk_point_pcm x y) same, but where x and y are PCM carrier values

let mk_point: int -> int -> point = mk_struct "point" point_fields
let mk_point_pcm: option int -> option int -> point_pcm_carrier = mk_struct_pcm "point" point_fields

/// Connections for the fields of a point

//[@@iter_unfold]
val _x: connection point_pcm (opt_pcm #int)
let _x = struct_field' "point" point_fields "x"

//[@@iter_unfold]
val _y: connection point_pcm (opt_pcm #int)
let _y = struct_field' "point" point_fields "y"

//[@@iter_unfold]
[@@__reduce__]
let x: field_of point_fields = mk_field_of point_fields "x"
[@@__reduce__]
let y: field_of point_fields = mk_field_of point_fields "y"

/// View for points

[@@__reduce__]
val point_view: sel_view point_pcm point false
let point_view = struct_view "point" point_fields

/// Explode and recombine

//val explode' (#opened: inames)
//  (p: ref 'a point_pcm)
//  (s: Ghost.erased point)
//: SteelGhostT unit opened
//    (pts_to_v p point_view s)
//    (fun _ -> pts_to_fields "point" point_fields p s)

val explode' (#opened: inames)
  (p: ref 'a (struct_pcm "point" point_fields))
  (s: Ghost.erased (struct "point" point_fields))
: SteelGhostT unit opened
    (pts_to_v p (struct_view "point" point_fields) s)
    (fun _ -> pts_to_fields "point" point_fields p s)

let explode' p = explode "point" point_fields p

(*

struct_def = f:(#a:Type -> (map: string&typedef -> a) -> (reduce: a -> a -> b) -> b){
  exists fields. 
}

struct_def_of_fields fields = fun f g -> reduce g (map f fields)

point_struct = normalize_term (struct_def_of_fields f g ["x", c_int; "y", c_int])
===> fun f g -> f ("x", c_int) `g` f ("y", c_int)

pcm_carrier (s: struct_def) = s (fun (_, td) -> td.carrier) (&)

struct_def a = {
  fields: s:a -> typedef; //itrivial typedef for undefined fields
}

struct_view : sel_view (struct_pcm fields) (struct_def (refine string p)) false
p ~~~> p /\ (fun x -> x =!= removed_field)


*)

val explode'' (#opened: inames)
  (p: ref 'a (struct_pcm "point" point_fields))
  (s: Ghost.erased (struct "point" point_fields))
: SteelGhostT unit opened
    (pts_to_v p (struct_view "point" point_fields) s)
    (fun _ ->
//(:struct_def) (fun (field, td) -> pts_to_v ..) Star)
//= struct_def ..
  pts_to_v
    (ref_focus p _x)
    (opt_view int)
    (s `struct_get'` x)
    `star`
  pts_to_v
    (ref_focus p _y)
    (opt_view int)
    (s `struct_get'` y))

//      pts_to_field "point" point_fields p s x `star`
//      pts_to_field "point" point_fields p s y)

#push-options "--print_implicits"

let explode'' p s = explode "point" point_fields p s

(*
(*

val explode'' (#opened: inames)
  (p: ref 'a point_pcm)
: SteelGhost unit opened
    (p `pts_to_view` point_view)
    (fun _ ->
      (ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      h' (ref_focus p _x `pts_to_view` c_int.view) == h (p `pts_to_view` point_view) `struct_get` "x" /\
      h' (ref_focus p _y `pts_to_view` c_int.view) == h (p `pts_to_view` point_view) `struct_get` "y")

let explode'' p = explode "point" point_fields p
*)

(*
val recombine' (#opened: inames)
  (p: ref 'a point_pcm)
: SteelGhost unit opened
    ((ref_focus p _x `pts_to_view` c_int.view) `star`
     (ref_focus p _y `pts_to_view` c_int.view))
    (fun _ -> p `pts_to_view` point_view)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      h (ref_focus p _x `pts_to_view` c_int.view) == h' (p `pts_to_view` point_view) `struct_get` "x" /\
      h (ref_focus p _y `pts_to_view` c_int.view) == h' (p `pts_to_view` point_view) `struct_get` "y")

let recombine' p = recombine "point" point_fields p
*)

#push-options "--debug PointStructSelectors --debug_level SMTQuery --log_queries --query_stats --fuel 0"
#restart-solver

[@@iter_unfold] let x: field_of point_fields = mk_field_of point_fields "x"
[@@iter_unfold] let y: field_of point_fields = mk_field_of point_fields "y"


module T = FStar.Tactics

let aux (p: ref 'a point_pcm) (h: rmem (p `pts_to_view` point_view))
  (h': rmem
     ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view)))
: Tot (squash (
   (norm norm_list
      (pts_to_fields "point" point_fields p h h' point_fields)
      ==
   norm norm_list (begin
      let pointprop =
      ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view))
      in
      (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
      h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get'` x) /\
      (can_be_split pointprop (ref_focus p _y `pts_to_view` c_int.view) /\
      h' (ref_focus p _y `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get'` y)
   end))))
= _ by (T.dump ""; T.smt ())

val explode' (#opened: inames)
  (p: ref 'a point_pcm)
: SteelGhost unit opened
    (p `pts_to_view` point_view)
    (fun _ -> pts_to_fields_vprop "point" point_fields p point_fields)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      norm norm_list
        (pts_to_fields "point" point_fields p h h' point_fields))
//(iter_and_fields fields (pts_to_field "point" fields p h h')))

let explode' p = explode "point" point_fields p

val explode'' (#opened: inames)
  (p: ref 'a point_pcm)
: SteelGhost unit opened
    (p `pts_to_view` struct_view "point" point_fields)
    (fun _ -> pts_to_fields_vprop "point" point_fields p point_fields)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      (
      let pointprop =
      (pts_to_fields_vprop "point" point_fields p point_fields)
      in
      (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
      h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get'` x)))

// let explode'' p = explode "point" point_fields p

assume val recombine (#opened: inames)
  (tag: string) (fields: struct_fields)
  (p: ref 'a (struct_pcm tag fields))
: SteelGhost unit opened
    (pts_to_fields_vprop tag fields p fields)
    (fun _ -> p `pts_to_view` struct_view tag fields)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      norm norm_list
        (pts_to_fields tag fields p h' h fields))


val explode''' (#opened: inames)
  (p: ref 'a point_pcm)
: SteelGhost unit opened
    (p `pts_to_view` point_view)
    (fun _ -> 
    ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view)))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      norm norm_list
        (pts_to_fields "point" point_fields p h h' point_fields))
//(iter_and_fields fields (pts_to_field "point" fields p h h')))

#push-options "--print_implicits"

unfold let norm' (s: list norm_step) (#a: Type) (x: a) : Tot (norm s a) =
  norm_spec s a;
  norm s x

unfold let norm''  (#a: Type) (x: a) : Tot (norm norm_list a) =
  norm_spec norm_list a;
  norm norm_list x

let aux'
  (p: ref 'a (struct_pcm "point" point_fields))
  (h': rmem (p `pts_to_view` point_view))
  : GTot int
= 
    ((h' (p `pts_to_view` point_view) `struct_get'` x))
    // <: (get_field point_fields x).view_type)) in
//  in let j: int = i in j
//= (norm norm_list (h' (p `pts_to_view` point_view) `struct_get` x) <: (get_field point_fields x).view_type) <: int
// TODO why are two coercions necessary?

//let aux'' (s: (Mktypedef?.view_type (get_field point_fields xc_)): int
//= s <: int

/// Reading a struct field
val struct_get
  (#tag: string) (#fields: struct_fields)
  (x: struct tag fields) (field: field_of fields)
: (get_field fields field).view_type

let explode''' p =
  explode "point" point_fields p;
  change_equal_slprop
    (pts_to_fields_vprop "point" point_fields p point_fields)
    ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view))

val zero_x
  (p: ref 'a (struct_pcm "point" point_fields))
: Steel unit
    (p `pts_to_view` point_view)
    (fun _ -> p `pts_to_view` point_view)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      norm norm_list (h' (p `pts_to_view` point_view) `struct_get` x == (0 <: c_int.view_type)))

let zero_x p =
  explode "point" point_fields p;
  slassert (
     ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view)));
  //recombine "point" point_fields p;
  sladmit(); return()

(*
val explode''' (#opened: inames)
  (p: ref 'a (struct_pcm "point" point_fields))
: SteelGhost unit opened
    (p `pts_to_view` struct_view "point" point_fields)
    (fun _ -> pts_to_fields_vprop "point" point_fields p point_fields)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let pointprop =
      (pts_to_fields_vprop "point" point_fields p point_fields)
      in
      (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
      h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x))

let testlemma p
    (h: rmem (p `pts_to_view` struct_view "point" point_fields))
    (h': rmem( pts_to_fields_vprop "point" point_fields p point_fields))
: Lemma
  (requires
  norm norm_list (let pointprop =
  (pts_to_fields_vprop "point" point_fields p point_fields)
  in
  (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
  h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x)
  ))
  (ensures
  norm norm_list (let pointprop =
  (pts_to_fields_vprop "point" point_fields p point_fields)
  in
  (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
  h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x)
  ))
= ()
*)
(*
let testlemma' (p: ref 'a point_pcm)
    (h: rmem (p `pts_to_view` struct_view "point" point_fields))
    (h': rmem( pts_to_fields_vprop "point" point_fields p point_fields))
: Lemma
  (requires
  norm norm_list (let pointprop =
  (pts_to_fields_vprop "point" point_fields p point_fields)
  in
  (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
  h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x)
  ))
  (ensures
  (let pointprop =
  (pts_to_fields_vprop "point" point_fields p point_fields)
  in
  (can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
  h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x)
  ))
= _ by (T.dump "") // T.norm norm_list; T.dump ""; T.tadmit()); admit()
*)

//let explode''' p = explode'' p

let aux p (h: rmem (p `pts_to_view` point_view))
  (h': rmem
     ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view)))
: Lemma
   (requires
      //norm [delta_attr [`%iter_unfold]; iota; primops; zeta]
      norm norm_list
      (pts_to_fields "point" point_fields p h h' point_fields))
   (ensures begin
      let pointprop =
      ((ref_focus p _x `pts_to_view` c_int.view) `star`
      (ref_focus p _y `pts_to_view` c_int.view))
      in
      can_be_split pointprop (ref_focus p _x `pts_to_view` c_int.view) /\
      h' (ref_focus p _x `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` x /\
      can_be_split pointprop (ref_focus p _y `pts_to_view` c_int.view) /\
      h' (ref_focus p _y `pts_to_view` c_int.view) === h (p `pts_to_view` point_view) `struct_get` y
   end)
= ()

/// Now, a contrived struct with twice as many fields (to stress-test)

//[@@__reduce__;iter_unfold]
let quad_fields: struct_fields = [
  "x", c_int;
  "y", c_int;
  "z", c_int;
  "w", c_int;
]
let quad = struct "quad" quad_fields

let quad_pcm_carrier = struct_pcm_carrier "quad" quad_fields
let quad_pcm: pcm quad_pcm_carrier = struct_pcm "quad" quad_fields

/// (mk_quad x y) represents (struct quad){.x = x, .y = y}
/// (mk_quad_pcm x y) same, but where x and y are PCM carrier values

let mk_quad: int -> int -> int -> int -> quad = mk_struct "quad" quad_fields
let mk_quad_pcm: option int -> option int -> option int -> option int -> quad_pcm_carrier = mk_struct_pcm "quad" quad_fields

/// Connections for the fields of a quad

[@@iter_unfold] let _quad_x: connection quad_pcm (opt_pcm #int) = struct_field "quad" quad_fields "x"
[@@iter_unfold] let _quad_y: connection quad_pcm (opt_pcm #int) = struct_field "quad" quad_fields "y"
[@@iter_unfold] let _quad_z: connection quad_pcm (opt_pcm #int) = struct_field "quad" quad_fields "z"
[@@iter_unfold] let _quad_w: connection quad_pcm (opt_pcm #int) = struct_field "quad" quad_fields "w"

/// View for quads

[@@iter_unfold] let quad_view: sel_view quad_pcm quad false = struct_view "quad" quad_fields

/// Explode and recombine

(*
val explode_quad' (#opened: inames)
  (p: ref 'a quad_pcm)
: SteelGhost unit opened
    (p `pts_to_view` struct_view "quad" quad_fields)
    (fun _ -> iter_star_fields quad_fields (pts_to_field_vprop "quad" quad_fields p))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      norm [delta_attr [`%iter_unfold]; iota; primops; zeta]
        (iter_and_fields quad_fields (pts_to_field "quad" quad_fields p h h')))

let explode_quad' p = explode "quad" quad_fields p
*)

(*
val explode_quad'' (#opened: inames)
  (p: ref 'a quad_pcm)
: SteelGhost unit opened
    (p `pts_to_view` quad_view)
    (fun _ ->
      (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
        (ref_focus p _quad_w `pts_to_view` c_int.view))))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let quadprop =
        (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
          (ref_focus p _quad_w `pts_to_view` c_int.view)))
      in
      can_be_split quadprop (ref_focus p _quad_x `pts_to_view` c_int.view) /\
      h' (ref_focus p _quad_x `pts_to_view` c_int.view) == h (p `pts_to_view` quad_view) `struct_get` "x" /\
      can_be_split quadprop (ref_focus p _quad_y `pts_to_view` c_int.view) /\
      h' (ref_focus p _quad_y `pts_to_view` c_int.view) == h (p `pts_to_view` quad_view) `struct_get` "y" /\
      can_be_split quadprop (ref_focus p _quad_z `pts_to_view` c_int.view) /\
      h' (ref_focus p _quad_z `pts_to_view` c_int.view) == h (p `pts_to_view` quad_view) `struct_get` "z" /\
      can_be_split quadprop (ref_focus p _quad_w `pts_to_view` c_int.view) /\
      h' (ref_focus p _quad_w `pts_to_view` c_int.view) == h (p `pts_to_view` quad_view) `struct_get` "w")
*)

#push-options "--z3rlimit 30 --query_stats"

#pop-options
#push-options "--fuel 2 --query_stats"

[@@iter_unfold] let x: field_of quad_fields = mk_field_of quad_fields "x"
[@@iter_unfold] let y: field_of quad_fields = mk_field_of quad_fields "y"
[@@iter_unfold] let z: field_of quad_fields = mk_field_of quad_fields "z"
[@@iter_unfold] let w: field_of quad_fields = mk_field_of quad_fields "w"

module T = FStar.Tactics

let norm_list = [
  delta_attr [`%iter_unfold];
  delta_only [
    `%map; `%mem; `%fst; `%Mktuple2?._1;
    `%assoc;
    `%Some?.v
  ];
  iota; primops; zeta
]

let quad_aux (p: ref 'a quad_pcm) (h: rmem (p `pts_to_view` quad_view))
  (h': rmem
     ((ref_focus p _quad_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
        (ref_focus p _quad_w `pts_to_view` c_int.view)))))
: squash
   ((
      norm norm_list//[delta_attr [`%iter_unfold]; iota; primops; zeta]
        (pts_to_fields "quad" quad_fields p h h' quad_fields))
   ==
   (begin
      let quadprop =
        (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
          (ref_focus p _quad_w `pts_to_view` c_int.view)))
      in
      (can_be_split quadprop (ref_focus p _quad_x `pts_to_view` c_int.view) /\
       h' (ref_focus p _quad_x `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` x) /\
      ((can_be_split quadprop (ref_focus p _quad_y `pts_to_view` c_int.view) /\
       h' (ref_focus p _quad_y `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` y) /\
       ((can_be_split quadprop (ref_focus p _quad_z `pts_to_view` c_int.view) /\
         h' (ref_focus p _quad_z `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` z) /\
         (can_be_split quadprop (ref_focus p _quad_w `pts_to_view` c_int.view) /\
          h' (ref_focus p _quad_w `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` w)))
   end))
= _ by (T.trefl ())
// assert_norm produces a stack overflow?
//_ by (
//    T.norm norm_list;
//    T.trefl ())

let quad_aux2 (p: ref 'a quad_pcm) (h: rmem (p `pts_to_view` quad_view))
  (h': rmem
     ((ref_focus p _quad_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
        (ref_focus p _quad_w `pts_to_view` c_int.view)))))
: squash
   ((
      norm norm_list//[delta_attr [`%iter_unfold]; iota; primops; zeta]
        (pts_to_fields "quad" quad_fields p h h' quad_fields))
   <==>
   norm norm_list (begin
      let quadprop =
        (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
          (ref_focus p _quad_w `pts_to_view` c_int.view)))
      in
      (can_be_split quadprop (ref_focus p _quad_x `pts_to_view` c_int.view) /\
       h' (ref_focus p _quad_x `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` x) /\
      ((can_be_split quadprop (ref_focus p _quad_y `pts_to_view` c_int.view) /\
       h' (ref_focus p _quad_y `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` y) /\
       ((can_be_split quadprop (ref_focus p _quad_z `pts_to_view` c_int.view) /\
         h' (ref_focus p _quad_z `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` z) /\
         (can_be_split quadprop (ref_focus p _quad_w `pts_to_view` c_int.view) /\
          h' (ref_focus p _quad_w `pts_to_view` c_int.view) === h (p `pts_to_view` quad_view) `struct_get` w)))
   end))
= () // _ by (T.trefl ())

(*
let quad_unfold_iter_star_fields p
: Lemma
    (norm [delta_attr [`%iter_unfold]; iota; primops; zeta]
    (iter_star_fields quad_fields (pts_to_field_vprop "quad" quad_fields p)) ==
     (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
        (ref_focus p _quad_w `pts_to_view` c_int.view))))
= ()
*)

#push-options "--query_stats"

let explode_quad'' p =
  explode "quad" quad_fields p;
  //quad_unfold_iter_star_fields p;
  //change_equal_slprop
  //  (iter_star_fields quad_fields (pts_to_field_vprop "quad" quad_fields p))
  //  ((ref_focus p _quad_x `pts_to_view` c_int.view) `star`
  //   ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
  //    ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
  //     (ref_focus p _quad_w `pts_to_view` c_int.view))));
  ()

(*
val recombine_quad' (#opened: inames)
  (p: ref 'a quad_pcm)
: SteelGhost unit opened
    ((ref_focus p _quad_x `pts_to_view` c_int.view) `star`
     ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
       (ref_focus p _quad_w `pts_to_view` c_int.view))))
    (fun _ -> p `pts_to_view` quad_view)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let quadprop =
        (ref_focus p _quad_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
          (ref_focus p _quad_w `pts_to_view` c_int.view)))
      in
      // assert (can_be_split' quadprop (ref_focus p _quad_x `pts_to_view` c_int.view));
      // assert (can_be_split' quadprop (ref_focus p _quad_y `pts_to_view` c_int.view));
      // assert (can_be_split' quadprop (ref_focus p _quad_z `pts_to_view` c_int.view));
      // assert (can_be_split' quadprop (ref_focus p _quad_w `pts_to_view` c_int.view));
      h (ref_focus p _quad_x `pts_to_view` c_int.view) == h' (p `pts_to_view` quad_view) `struct_get` "x" /\
      h (ref_focus p _quad_y `pts_to_view` c_int.view) == h' (p `pts_to_view` quad_view) `struct_get` "y" /\
      h (ref_focus p _quad_z `pts_to_view` c_int.view) == h' (p `pts_to_view` quad_view) `struct_get` "z" /\
      h (ref_focus p _quad_w `pts_to_view` c_int.view) == h' (p `pts_to_view` quad_view) `struct_get` "w")

let recombine_quad' p =
  quad_unfold_iter_star_fields p;
  change_equal_slprop
    ((ref_focus p _quad_x `pts_to_view` c_int.view) `star`
     ((ref_focus p _quad_y `pts_to_view` c_int.view) `star`
      ((ref_focus p _quad_z `pts_to_view` c_int.view) `star`
       (ref_focus p _quad_w `pts_to_view` c_int.view))))
    (iter_star_fields quad_fields (pts_to_field_vprop "quad" quad_fields p));
  recombine "quad" quad_fields p
*)

/// 5 fields!

//[@@__reduce__;iter_unfold]
let quint_fields: struct_fields = [
  "x", c_int;
  "y", c_int;
  "z", c_int;
  "w", c_int;
  "v", c_int;
]
let quint = struct "quint" quint_fields

let quint_pcm_carrier = struct_pcm_carrier "quint" quint_fields
let quint_pcm: pcm quint_pcm_carrier = struct_pcm "quint" quint_fields

let mk_quint: int -> int -> int -> int -> int -> quint = mk_struct "quint" quint_fields
let mk_quint_pcm: option int -> option int -> option int -> option int -> option int -> quint_pcm_carrier = mk_struct_pcm "quint" quint_fields

/// Connections for the fields of a quint

let _quint_x: connection quint_pcm (opt_pcm #int) = struct_field "quint" quint_fields "x"
let _quint_y: connection quint_pcm (opt_pcm #int) = struct_field "quint" quint_fields "y"
let _quint_z: connection quint_pcm (opt_pcm #int) = struct_field "quint" quint_fields "z"
let _quint_w: connection quint_pcm (opt_pcm #int) = struct_field "quint" quint_fields "w"
let _quint_v: connection quint_pcm (opt_pcm #int) = struct_field "quint" quint_fields "v"

/// View for quints

let quint_view: sel_view quint_pcm quint false = struct_view "quint" quint_fields

/// Explode and recombine

(*
val explode_quint' (#opened: inames)
  (p: ref 'a quint_pcm)
: SteelGhost unit opened
    (p `pts_to_view` struct_view "quint" quint_fields)
    (fun _ -> iter_star_fields quint_fields (pts_to_field_vprop "quint" quint_fields p))
    (requires fun _ -> True)
    (ensures fun h _ h' -> iter_and_fields quint_fields (pts_to_field "quint" quint_fields p h h'))

let explode_quint' p = explode "quint" quint_fields p
*)

#restart-solver

val explode_quint'' (#opened: inames)
  (p: ref 'a quint_pcm)
: SteelGhost unit opened
    (p `pts_to_view` quint_view)
    (fun _ ->
      (ref_focus p _quint_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
         (ref_focus p _quint_v `pts_to_view` c_int.view)))))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let quintprop =
        (ref_focus p _quint_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
          ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
           (ref_focus p _quint_v `pts_to_view` c_int.view))))
      in
      can_be_split quintprop (ref_focus p _quint_x `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_x `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "x" /\
      can_be_split quintprop (ref_focus p _quint_y `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_y `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "y" /\
      can_be_split quintprop (ref_focus p _quint_z `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_z `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "z" /\
      can_be_split quintprop (ref_focus p _quint_w `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_w `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "w" /\
      can_be_split quintprop (ref_focus p _quint_v `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_v `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "v")

let aux p (h: rmem (p `pts_to_view` quint_view))
  (h': rmem
     ((ref_focus p _quint_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
         (ref_focus p _quint_v `pts_to_view` c_int.view))))))
: Lemma
   (requires
      norm [delta_attr [`%iter_unfold]; iota; primops; zeta]
      (pts_to_fields "quint" quint_fields p h h' quint_fields))
   (ensures begin
      let quintprop =
        (ref_focus p _quint_x `pts_to_view` c_int.view) `star`
        ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
         ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
          ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
           (ref_focus p _quint_v `pts_to_view` c_int.view))))
      in
      can_be_split quintprop (ref_focus p _quint_x `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_x `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "x" /\
      can_be_split quintprop (ref_focus p _quint_y `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_y `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "y" /\
      can_be_split quintprop (ref_focus p _quint_z `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_z `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "z" /\
      can_be_split quintprop (ref_focus p _quint_w `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_w `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "w" /\
      can_be_split quintprop (ref_focus p _quint_v `pts_to_view` c_int.view) /\
      h' (ref_focus p _quint_v `pts_to_view` c_int.view) == h (p `pts_to_view` quint_view) `struct_get` "v"
   end)
= admit()

(*
let quint_unfold_iter_star_fields p
: Lemma
    (iter_star_fields quint_fields (pts_to_field_vprop "quint" quint_fields p) ==
     (ref_focus p _quint_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
         (ref_focus p _quint_v `pts_to_view` c_int.view)))))
= ()
*)

#restart-solver

//#push-options "--z3rlimit 30"

let explode_quint'' p =
  explode "quint" quint_fields p;
  //quint_unfold_iter_star_fields p;
  //change_equal_slprop
  //  (iter_star_fields quint_fields (pts_to_field_vprop "quint" quint_fields p))
  //  ((ref_focus p _quint_x `pts_to_view` c_int.view) `star`
  //   ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
  //    ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
  //     ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
  //      (ref_focus p _quint_v `pts_to_view` c_int.view)))));
  ()

//#pop-options

val recombine_quint' (#opened: inames)
  (p: ref 'a quint_pcm)
: SteelGhost unit opened
    ((ref_focus p _quint_x `pts_to_view` c_int.view) `star`
     ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
      ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
       ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
        (ref_focus p _quint_v `pts_to_view` c_int.view)))))
    (fun _ -> p `pts_to_view` quint_view)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let quintprop =
        ((ref_focus p _quint_x `pts_to_view` c_int.view) `star`
         ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
          ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
           ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
            (ref_focus p _quint_v `pts_to_view` c_int.view)))))
      in
      assert (can_be_split' quintprop (ref_focus p _quint_x `pts_to_view` c_int.view));
      assert (can_be_split' quintprop (ref_focus p _quint_y `pts_to_view` c_int.view));
      assert (can_be_split' quintprop (ref_focus p _quint_z `pts_to_view` c_int.view));
      assert (can_be_split' quintprop (ref_focus p _quint_w `pts_to_view` c_int.view));
      assert (can_be_split' quintprop (ref_focus p _quint_v `pts_to_view` c_int.view));
      h (ref_focus p _quint_x `pts_to_view` c_int.view) == h' (p `pts_to_view` quint_view) `struct_get` "x" /\
      h (ref_focus p _quint_y `pts_to_view` c_int.view) == h' (p `pts_to_view` quint_view) `struct_get` "y" /\
      h (ref_focus p _quint_z `pts_to_view` c_int.view) == h' (p `pts_to_view` quint_view) `struct_get` "z" /\
      h (ref_focus p _quint_w `pts_to_view` c_int.view) == h' (p `pts_to_view` quint_view) `struct_get` "w" /\
      h (ref_focus p _quint_v `pts_to_view` c_int.view) == h' (p `pts_to_view` quint_view) `struct_get` "v")

#push-options "--z3rlimit 20"

let recombine_quint' p =
  quint_unfold_iter_star_fields p;
  change_equal_slprop
    ((ref_focus p _quint_x `pts_to_view` c_int.view) `star`
     ((ref_focus p _quint_y `pts_to_view` c_int.view) `star`
      ((ref_focus p _quint_z `pts_to_view` c_int.view) `star`
       ((ref_focus p _quint_w `pts_to_view` c_int.view) `star`
        (ref_focus p _quint_v `pts_to_view` c_int.view)))))
    (iter_star_fields quint_fields (pts_to_field_vprop "quint" quint_fields p));
  recombine "quint" quint_fields p

#pop-options

/// 8 fields:

let oct_fields: struct_fields = [
  "x", c_int;
  "y", c_int;
  "z", c_int;
  "w", c_int;
  "v", c_int;
  "u", c_int;
  "t", c_int;
  "s", c_int;
]
let oct = struct "oct" oct_fields

let oct_pcm_carrier = struct_pcm_carrier "oct" oct_fields
let oct_pcm: pcm oct_pcm_carrier = struct_pcm "oct" oct_fields

let mk_oct: int -> int -> int -> int -> int -> int -> int -> int -> oct = mk_struct "oct" oct_fields
let mk_oct_pcm: option int -> option int -> option int -> option int -> option int -> option int -> option int -> option int -> oct_pcm_carrier = mk_struct_pcm "oct" oct_fields

/// Connections for the fields of a oct

let _oct_x: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "x"
let _oct_y: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "y"
let _oct_z: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "z"
let _oct_w: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "w"
let _oct_v: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "v"
let _oct_u: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "u"
let _oct_t: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "t"
let _oct_s: connection oct_pcm (opt_pcm #int) = struct_field "oct" oct_fields "s"

/// View for octs

let oct_view: sel_view oct_pcm oct false = struct_view "oct" oct_fields

/// Explode and recombine

val explode_oct' (#opened: inames)
  (p: ref 'a oct_pcm)
: SteelGhost unit opened
    (p `pts_to_view` struct_view "oct" oct_fields)
    (fun _ -> iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p))
    (requires fun _ -> True)
    (ensures fun h _ h' -> iter_and_fields oct_fields (pts_to_field "oct" oct_fields p h h'))

let explode_oct' p = explode "oct" oct_fields p

val explode_oct'' (#opened: inames)
  (p: ref 'a oct_pcm)
: SteelGhost unit opened
    (p `pts_to_view` oct_view)
    (fun _ ->
      ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
        ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
            ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
             (ref_focus p _oct_s `pts_to_view` c_int.view)))))))))
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      True)
      // let octprop =
      //   ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
      //    ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
      //     ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
      //      ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
      //       ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
      //        ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
      //         ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
      //          (ref_focus p _oct_s `pts_to_view` c_int.view))))))))
      // in
      // assert (can_be_split' octprop (ref_focus p _oct_x `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_y `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_z `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_w `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_v `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_u `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_t `pts_to_view` c_int.view));
      // assert (can_be_split' octprop (ref_focus p _oct_s `pts_to_view` c_int.view));
      // h' (ref_focus p _oct_x `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "x" /\
      // h' (ref_focus p _oct_y `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "y" /\
      // h' (ref_focus p _oct_z `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "z" /\
      // h' (ref_focus p _oct_w `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "w" /\
      // h' (ref_focus p _oct_v `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "v" /\
      // h' (ref_focus p _oct_u `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "u" /\
      // h' (ref_focus p _oct_t `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "t" /\
      // h' (ref_focus p _oct_s `pts_to_view` c_int.view) == h (p `pts_to_view` oct_view) `struct_get` "s")

let oct_unfold_iter_star_fields p
: Lemma
    (iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p) ==
     ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
            (ref_focus p _oct_s `pts_to_view` c_int.view)))))))))
= assert_norm (
    iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p) ==
     ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
            (ref_focus p _oct_s `pts_to_view` c_int.view)))))))))

#restart-solver
#push-options "--z3rlimit 40 --query_stats"

let explode_oct'' p =
  explode "oct" oct_fields p;
  // OOMs
  //change_slprop_rel
  //  (iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p))
  //  ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
  //    ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
  //     ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
  //      ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
  //       ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
  //        ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
  //         ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
  //          (ref_focus p _oct_s `pts_to_view` c_int.view))))))))
  //  (fun _ _ -> True)
  //  (fun m ->
  //    assert_norm
  //      (iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p) ==
  //      ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
  //        ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
  //         ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
  //          ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
  //           ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
  //            ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
  //             ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
  //              (ref_focus p _oct_s `pts_to_view` c_int.view))))))))));
  oct_unfold_iter_star_fields p;
  change_equal_slprop
    (iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p))
    ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
            (ref_focus p _oct_s `pts_to_view` c_int.view))))))));
  ()

#pop-options

val recombine_oct' (#opened: inames)
  (p: ref 'a oct_pcm)
: SteelGhost unit opened
    ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
     ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
      ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
        (ref_focus p _oct_v `pts_to_view` c_int.view)))))
    (fun _ -> p `pts_to_view` oct_view)
    (requires fun _ -> True)
    (ensures fun h _ h' ->
      let octprop =
        ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
            (ref_focus p _oct_v `pts_to_view` c_int.view)))))
      in
      assert (can_be_split' octprop (ref_focus p _oct_x `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_y `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_z `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_w `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_v `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_u `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_t `pts_to_view` c_int.view));
      assert (can_be_split' octprop (ref_focus p _oct_s `pts_to_view` c_int.view));
      h (ref_focus p _oct_x `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "x" /\
      h (ref_focus p _oct_y `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "y" /\
      h (ref_focus p _oct_z `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "z" /\
      h (ref_focus p _oct_w `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "w" /\
      h (ref_focus p _oct_v `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "v" /\
      h (ref_focus p _oct_u `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "u" /\
      h (ref_focus p _oct_t `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "t" /\
      h (ref_focus p _oct_s `pts_to_view` c_int.view) == h' (p `pts_to_view` oct_view) `struct_get` "s")

#restart-solver
#push-options "--z3rlimit 20"

let recombine_oct' p =
  oct_unfold_iter_star_fields p;
  change_equal_slprop
    ((ref_focus p _oct_x `pts_to_view` c_int.view) `star`
      ((ref_focus p _oct_y `pts_to_view` c_int.view) `star`
       ((ref_focus p _oct_z `pts_to_view` c_int.view) `star`
        ((ref_focus p _oct_w `pts_to_view` c_int.view) `star`
         ((ref_focus p _oct_v `pts_to_view` c_int.view) `star`
          ((ref_focus p _oct_u `pts_to_view` c_int.view) `star`
           ((ref_focus p _oct_t `pts_to_view` c_int.view) `star`
            (ref_focus p _oct_s `pts_to_view` c_int.view))))))))
    (iter_star_fields oct_fields (pts_to_field_vprop "oct" oct_fields p));
  recombine "oct" oct_fields p

#pop-options
*)