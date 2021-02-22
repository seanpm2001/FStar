module FStar.Trees

#set-options "--fuel 1 --ifuel 1 --z3rlimit 20"

(*** Type definitions *)

(**** The tree structure *)

type tree (a: Type) =
  | Leaf : tree a
  | Node: data: a -> left: tree a -> right: tree a -> tree a

(**** Binary search trees *)

type node_data (a b: Type) = {
  key: a;
  payload: b;
}

let kv_tree (a: Type) (b: Type) = tree (node_data a b)

class ordered (a: Type) = {
  compare: a -> a -> int;
  refl: squash (forall x. compare x x == 0);
  antisym: squash (forall x y. compare x y > 0 <==> compare y x < 0);
  trans: squash (forall x y z. compare x y >= 0 /\ compare y z >= 0 ==> compare x z >= 0)
}

let rec forall_keys (#a #b: Type) (t: kv_tree a b) (cond: a -> bool) : bool =
  match t with
  | Leaf -> true
  | Node data left right ->
    cond data.key && forall_keys left cond && forall_keys right cond

let key_left (#a: Type) {| d: ordered a |} (root key: a) =
  d.compare root key >= 0

let key_right (#a: Type) {| d: ordered a |} (root key: a) =
  d.compare root key <= 0

let rec is_bst (#a #b: Type) {| d: ordered a |} (x: kv_tree a b) : bool =
  match x with
  | Leaf -> true
  | Node data left right ->
    is_bst left && is_bst right &&
    forall_keys left (key_left data.key) &&
    forall_keys right (key_right data.key)

let bst (a b: Type) {| d: ordered a |} = x:kv_tree a b{is_bst x}

(*** Operations *)

(**** Lookup *)

let rec mem (#a: Type) (r: tree a) (x: a) : prop =
  match r with
  | Leaf -> False
  | Node data left right ->
    (data == x) \/ (mem right x) \/ mem left x

let rec bst_search (#a #b: Type) {| d: ordered a |} (x: bst a b) (key: a) : option b =
  match x with
  | Leaf -> None
  | Node data left right ->
    let delta = d.compare data.key key in
    if delta < 0 then bst_search right key else
    if delta > 0 then bst_search left key else
    Some data.payload

(**** Height *)

let rec height (#a: Type) (x: tree a) : nat =
  match x with
  | Leaf -> 0
  | Node data left right ->
    if height left > height right then (height left) + 1
    else (height right) + 1

(**** Append *)

let rec append_left (#a: Type) (x: tree a) (v: a) : tree a =
  match x with
  | Leaf -> Node v Leaf Leaf
  | Node x left right -> Node x (append_left left v) right

let rec append_right (#a: Type) (x: tree a) (v: a) : tree a =
  match x with
  | Leaf -> Node v Leaf Leaf
  | Node x left right -> Node x left (append_right right v)


(**** Insertion *)

(**** BST insertion *)

let rec insert_bst (#a #b: Type) {| d: ordered a |} (x: bst a b) (key: a) (payload: b) : kv_tree a b =
  match x with
  | Leaf -> Node ({key; payload}) Leaf Leaf
  | Node data left right ->
    let delta = d.compare data.key key in
    if delta >= 0 then begin
      let new_left = insert_bst left key payload in
      Node data new_left right
    end else begin
      let new_right = insert_bst right key payload in
      Node data left new_right
    end

let rec insert_bst_preserves_forall_keys
  (#a #b: Type)
  {| d: ordered a |}
  (x: bst a b)
  (key: a)
  (payload: b)
  (cond: a -> bool)
    : Lemma
      (requires (forall_keys x cond /\ cond key))
      (ensures (forall_keys (insert_bst x key payload) cond))
  =
  match x with
  | Leaf -> ()
  | Node data left right ->
    let delta = d.compare data.key key in
    if delta >= 0 then
      insert_bst_preserves_forall_keys left key payload cond
    else
      insert_bst_preserves_forall_keys right key payload cond

let rec insert_bst_preserves_bst
  (#a #b: Type)
  {| d: ordered a |}
  (x: bst a b)
  (key: a)
  (payload: b)
    : Lemma(is_bst (insert_bst x key payload))
  =
  match x with
  | Leaf -> ()
  | Node data left right ->
    let delta = d.compare data.key key in
    if delta >= 0 then begin
      insert_bst_preserves_forall_keys left key payload (key_left data.key);
      insert_bst_preserves_bst left key payload
    end else begin
      insert_bst_preserves_forall_keys right key payload (key_right data.key);
      insert_bst_preserves_bst right key payload
    end

(**** AVL insertion *)

let rec is_balanced (#a: Type) (x: tree a) : bool =
  match x with
  | Leaf -> true
  | Node data left right ->
    (height left - height right) <= 1 &&
    (height right - height left) <= 1 &&
    is_balanced(right) &&
    is_balanced(left)

let is_avl (#a #b: Type) {| d: ordered a |} (x: kv_tree a b) : prop =
  is_bst(x) /\ is_balanced(x)

let avl (a b: Type) {| d: ordered a |} = x: kv_tree a b {is_avl x}

let rotate_left (#a: Type) (r: tree a) : tree a =
  match r with
  | Node x t1 (Node z t2 t3) -> Node z (Node x t1 t2) t3
  | _ -> r

let rotate_right (#a: Type) (r: tree a) : tree a =
  match r with
  | Node x (Node z t1 t2) t3 -> Node z t1 (Node x t2 t3)
  | _ -> r

let rotate_right_left (#a: Type) (r: tree a) : tree a =
  match r with
  | Node x t1 (Node z (Node y t2 t3) t4) -> Node y (Node x t1 t2) (Node z t3 t4)
  | _ -> r

let rotate_left_right (#a: Type) (r: tree a) : tree a =
  match r with
  | Node x (Node z t1 (Node y t2 t3)) t4 -> Node y (Node z t1 t2) (Node x t3 t4)
  | _ -> r

(** rotate preserves bst *)
let rec forall_keys_trans (#a #b: Type) (t: kv_tree a b) (cond1 cond2: a -> bool)
  : Lemma (requires (forall x. cond1 x ==> cond2 x) /\ forall_keys t cond1)
          (ensures forall_keys t cond2)
  = match t with
  | Leaf -> ()
  | Node data left right ->
    forall_keys_trans left cond1 cond2; forall_keys_trans right cond1 cond2

let rotate_left_bst (#a #b:Type) {| d : ordered a |} (r:kv_tree a b)
  : Lemma (requires is_bst r) (ensures is_bst (rotate_left r))
  = match r with
  | Node x t1 (Node z t2 t3) ->
      assert (is_bst (Node z t2 t3));
      assert (is_bst (Node x t1 t2));
      forall_keys_trans t1 (key_left x.key) (key_left z.key)
  | _ -> ()

let rotate_right_bst (#a #b:Type) {| d : ordered a |} (r:kv_tree a b)
  : Lemma (requires is_bst r) (ensures is_bst (rotate_right r))
  = match r with
  | Node x (Node z t1 t2) t3 ->
      assert (is_bst (Node z t1 t2));
      assert (is_bst (Node x t2 t3));
      forall_keys_trans t3 (key_right x.key) (key_right z.key)
  | _ -> ()


let rotate_right_left_bst (#a #b:Type) {| d : ordered a |} (r:kv_tree a b)
  : Lemma (requires is_bst r) (ensures is_bst (rotate_right_left r))
  = match r with
  | Node x t1 (Node z (Node y t2 t3) t4) ->
    assert (is_bst (Node z (Node y t2 t3) t4));
    assert (is_bst (Node y t2 t3));
    let left = Node x t1 t2 in
    let right = Node z t3 t4 in

    assert (forall_keys (Node y t2 t3) (key_right x.key));
    assert (forall_keys t2 (key_right x.key));
    assert (is_bst left);

    assert (is_bst right);

    forall_keys_trans t1 (key_left x.key) (key_left y.key);
    assert (forall_keys left (key_left y.key));

    forall_keys_trans t4 (key_right z.key) (key_right y.key);
    assert (forall_keys right (key_right y.key))

  | _ -> ()


let rotate_left_right_bst (#a #b:Type) {| d : ordered a |} (r:kv_tree a b)
  : Lemma (requires is_bst r) (ensures is_bst (rotate_left_right r))
  = match r with
  | Node x (Node z t1 (Node y t2 t3)) t4 ->
    // Node y (Node z t1 t2) (Node x t3 t4)
    assert (is_bst (Node z t1 (Node y t2 t3)));
    assert (is_bst (Node y t2 t3));
    let left = Node z t1 t2 in
    let right = Node x t3 t4 in

    assert (is_bst left);

    assert (forall_keys (Node y t2 t3) (key_left x.key));
    assert (forall_keys t2 (key_left x.key));
    assert (is_bst right);

    forall_keys_trans t1 (key_left z.key) (key_left y.key);
    assert (forall_keys left (key_left y.key));

    forall_keys_trans t4 (key_right x.key) (key_right y.key);
    assert (forall_keys right (key_right y.key))

  | _ -> ()


(** Balancing operation for AVLs *)

let rebalance_avl (#a #b: Type) {| d: ordered a |} (x: kv_tree a b) : kv_tree a b =
    match x with
    | Leaf -> x
    | Node data left right ->

      if is_balanced(x) then (x)
      else (

        if (height left - height right) > 1 then (
        match left with
        | Node ldata lleft lright ->
            if d.compare data.key ldata.key > 0 then (
              rotate_left_right(x)
            ) else (
              rotate_right(x)
            )
        | _ -> x

        ) else (
        if (height left - height right) < -1 then (
        match right with
        | Node rdata rleft rright ->
            if d.compare data.key rdata.key > 0 then (
              rotate_left(x)
            ) else (
              rotate_right_left(x)
            )
        | _ -> x
        ) else (
          x
        )
      )
    )

let rebalance_avl_proof (#a #b: Type) {| d: ordered a |} (x: kv_tree a b) : Lemma
  (requires is_bst x /\ (
    match x with
    | Leaf -> True
    | Node data left right ->
      is_balanced left /\ is_balanced right /\
      height left - height right <= 2 /\ height right - height left <= 2
    )
  )
  (ensures is_avl (rebalance_avl x))
  = match x with
    | Leaf -> ()
    | Node data left right ->
      if is_balanced x then ()
      else (
        if height left - height right > 1 then (
        match left with
        | Node ldata lleft lright ->
          if d.compare data.key ldata.key > 0 then (
            admit()
          ) else (
            admit()
          )
        | _ -> ()
        ) else if height left - height right < -1 then (
          admit()
        ) else (
          ()
        )
      )


let rec insert_avl (#a #b: Type) {| d: ordered a |} (x: avl a b) (key: a) (payload: b): kv_tree a b =
  match x with
  | Leaf -> Node ({key; payload}) Leaf Leaf
  | Node data left right ->
    let delta = d.compare data.key key in
    if delta >= 0 then (
      let new_left = insert_avl left key payload in
      let tmp = Node data new_left right in
      rebalance_avl(tmp)
    ) else (
      let new_right = insert_avl right key payload in
      let tmp = Node data left new_right in
      rebalance_avl(tmp)
    )
