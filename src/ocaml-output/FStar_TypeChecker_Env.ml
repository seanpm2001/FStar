
open Prims
type binding =
| Binding_var of FStar_Syntax_Syntax.bv
| Binding_lid of (FStar_Ident.lident * FStar_Syntax_Syntax.tscheme)
| Binding_sig of (FStar_Ident.lident Prims.list * FStar_Syntax_Syntax.sigelt)
| Binding_univ of FStar_Syntax_Syntax.univ_name
| Binding_sig_inst of (FStar_Ident.lident Prims.list * FStar_Syntax_Syntax.sigelt * FStar_Syntax_Syntax.universes)


let uu___is_Binding_var : binding  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Binding_var (_0) -> begin
true
end
| uu____29 -> begin
false
end))


let __proj__Binding_var__item___0 : binding  ->  FStar_Syntax_Syntax.bv = (fun projectee -> (match (projectee) with
| Binding_var (_0) -> begin
_0
end))


let uu___is_Binding_lid : binding  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Binding_lid (_0) -> begin
true
end
| uu____43 -> begin
false
end))


let __proj__Binding_lid__item___0 : binding  ->  (FStar_Ident.lident * FStar_Syntax_Syntax.tscheme) = (fun projectee -> (match (projectee) with
| Binding_lid (_0) -> begin
_0
end))


let uu___is_Binding_sig : binding  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Binding_sig (_0) -> begin
true
end
| uu____64 -> begin
false
end))


let __proj__Binding_sig__item___0 : binding  ->  (FStar_Ident.lident Prims.list * FStar_Syntax_Syntax.sigelt) = (fun projectee -> (match (projectee) with
| Binding_sig (_0) -> begin
_0
end))


let uu___is_Binding_univ : binding  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Binding_univ (_0) -> begin
true
end
| uu____85 -> begin
false
end))


let __proj__Binding_univ__item___0 : binding  ->  FStar_Syntax_Syntax.univ_name = (fun projectee -> (match (projectee) with
| Binding_univ (_0) -> begin
_0
end))


let uu___is_Binding_sig_inst : binding  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Binding_sig_inst (_0) -> begin
true
end
| uu____101 -> begin
false
end))


let __proj__Binding_sig_inst__item___0 : binding  ->  (FStar_Ident.lident Prims.list * FStar_Syntax_Syntax.sigelt * FStar_Syntax_Syntax.universes) = (fun projectee -> (match (projectee) with
| Binding_sig_inst (_0) -> begin
_0
end))

type delta_level =
| NoDelta
| Inlining
| Eager_unfolding_only
| Unfold of FStar_Syntax_Syntax.delta_depth


let uu___is_NoDelta : delta_level  ->  Prims.bool = (fun projectee -> (match (projectee) with
| NoDelta -> begin
true
end
| uu____127 -> begin
false
end))


let uu___is_Inlining : delta_level  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Inlining -> begin
true
end
| uu____131 -> begin
false
end))


let uu___is_Eager_unfolding_only : delta_level  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Eager_unfolding_only -> begin
true
end
| uu____135 -> begin
false
end))


let uu___is_Unfold : delta_level  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Unfold (_0) -> begin
true
end
| uu____140 -> begin
false
end))


let __proj__Unfold__item___0 : delta_level  ->  FStar_Syntax_Syntax.delta_depth = (fun projectee -> (match (projectee) with
| Unfold (_0) -> begin
_0
end))


type mlift =
FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.typ

type edge =
{msource : FStar_Ident.lident; mtarget : FStar_Ident.lident; mlift : FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.typ}

type effects =
{decls : FStar_Syntax_Syntax.eff_decl Prims.list; order : edge Prims.list; joins : (FStar_Ident.lident * FStar_Ident.lident * FStar_Ident.lident * mlift * mlift) Prims.list}


type cached_elt =
((FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ), (FStar_Syntax_Syntax.sigelt * FStar_Syntax_Syntax.universes Prims.option)) FStar_Util.either

type env =
{solver : solver_t; range : FStar_Range.range; curmodule : FStar_Ident.lident; gamma : binding Prims.list; gamma_cache : cached_elt FStar_Util.smap; modules : FStar_Syntax_Syntax.modul Prims.list; expected_typ : FStar_Syntax_Syntax.typ Prims.option; sigtab : FStar_Syntax_Syntax.sigelt FStar_Util.smap; is_pattern : Prims.bool; instantiate_imp : Prims.bool; effects : effects; generalize : Prims.bool; letrecs : (FStar_Syntax_Syntax.lbname * FStar_Syntax_Syntax.typ) Prims.list; top_level : Prims.bool; check_uvars : Prims.bool; use_eq : Prims.bool; is_iface : Prims.bool; admit : Prims.bool; lax : Prims.bool; lax_universes : Prims.bool; type_of : env  ->  FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.typ * guard_t); universe_of : env  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.universe; use_bv_sorts : Prims.bool; qname_and_index : (FStar_Ident.lident * Prims.int) Prims.option} 
 and solver_t =
{init : env  ->  Prims.unit; push : Prims.string  ->  Prims.unit; pop : Prims.string  ->  Prims.unit; mark : Prims.string  ->  Prims.unit; reset_mark : Prims.string  ->  Prims.unit; commit_mark : Prims.string  ->  Prims.unit; encode_modul : env  ->  FStar_Syntax_Syntax.modul  ->  Prims.unit; encode_sig : env  ->  FStar_Syntax_Syntax.sigelt  ->  Prims.unit; solve : (Prims.unit  ->  Prims.string) Prims.option  ->  env  ->  FStar_Syntax_Syntax.typ  ->  Prims.unit; is_trivial : env  ->  FStar_Syntax_Syntax.typ  ->  Prims.bool; finish : Prims.unit  ->  Prims.unit; refresh : Prims.unit  ->  Prims.unit} 
 and guard_t =
{guard_f : FStar_TypeChecker_Common.guard_formula; deferred : FStar_TypeChecker_Common.deferred; univ_ineqs : FStar_TypeChecker_Common.univ_ineq Prims.list; implicits : (Prims.string * env * FStar_Syntax_Syntax.uvar * FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.typ * FStar_Range.range) Prims.list}


type implicits =
(Prims.string * env * FStar_Syntax_Syntax.uvar * FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.typ * FStar_Range.range) Prims.list


type env_t =
env


type sigtable =
FStar_Syntax_Syntax.sigelt FStar_Util.smap


let should_verify : env  ->  Prims.bool = (fun env -> (((not (env.lax)) && (not (env.admit))) && (FStar_Options.should_verify env.curmodule.FStar_Ident.str)))


let visible_at : delta_level  ->  FStar_Syntax_Syntax.qualifier  ->  Prims.bool = (fun d q -> (match (((d), (q))) with
| ((NoDelta, _)) | ((Eager_unfolding_only, FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen)) | ((Unfold (_), FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen)) | ((Unfold (_), FStar_Syntax_Syntax.Visible_default)) -> begin
true
end
| (Inlining, FStar_Syntax_Syntax.Inline_for_extraction) -> begin
true
end
| uu____764 -> begin
false
end))


let default_table_size : Prims.int = (Prims.parse_int "200")


let new_sigtab = (fun uu____774 -> (FStar_Util.smap_create default_table_size))


let new_gamma_cache = (fun uu____782 -> (FStar_Util.smap_create (Prims.parse_int "100")))


let initial_env : (env  ->  FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.typ * guard_t))  ->  (env  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.universe)  ->  solver_t  ->  FStar_Ident.lident  ->  env = (fun type_of universe_of solver module_lid -> (let _0_160 = (new_gamma_cache ())
in (let _0_159 = (new_sigtab ())
in {solver = solver; range = FStar_Range.dummyRange; curmodule = module_lid; gamma = []; gamma_cache = _0_160; modules = []; expected_typ = None; sigtab = _0_159; is_pattern = false; instantiate_imp = true; effects = {decls = []; order = []; joins = []}; generalize = true; letrecs = []; top_level = false; check_uvars = false; use_eq = false; is_iface = false; admit = false; lax = false; lax_universes = false; type_of = type_of; universe_of = universe_of; use_bv_sorts = false; qname_and_index = None})))


let sigtab : env  ->  FStar_Syntax_Syntax.sigelt FStar_Util.smap = (fun env -> env.sigtab)


let gamma_cache : env  ->  cached_elt FStar_Util.smap = (fun env -> env.gamma_cache)

type env_stack_ops =
{es_push : env  ->  env; es_mark : env  ->  env; es_reset_mark : env  ->  env; es_commit_mark : env  ->  env; es_pop : env  ->  env; es_incr_query_index : env  ->  env}


let stack_ops : env_stack_ops = (

let query_indices = (FStar_Util.mk_ref (([])::[]))
in (

let push_query_indices = (fun uu____944 -> (

let uu____945 = (FStar_ST.read query_indices)
in (match (uu____945) with
| [] -> begin
(failwith "Empty query indices!")
end
| uu____959 -> begin
(let _0_163 = (let _0_162 = (FStar_List.hd (FStar_ST.read query_indices))
in (let _0_161 = (FStar_ST.read query_indices)
in (_0_162)::_0_161))
in (FStar_ST.write query_indices _0_163))
end)))
in (

let pop_query_indices = (fun uu____991 -> (

let uu____992 = (FStar_ST.read query_indices)
in (match (uu____992) with
| [] -> begin
(failwith "Empty query indices!")
end
| (hd)::tl -> begin
(FStar_ST.write query_indices tl)
end)))
in (

let add_query_index = (fun uu____1029 -> (match (uu____1029) with
| (l, n) -> begin
(

let uu____1034 = (FStar_ST.read query_indices)
in (match (uu____1034) with
| (hd)::tl -> begin
(FStar_ST.write query_indices (((((l), (n)))::hd)::tl))
end
| uu____1068 -> begin
(failwith "Empty query indices")
end))
end))
in (

let peek_query_indices = (fun uu____1079 -> (FStar_List.hd (FStar_ST.read query_indices)))
in (

let commit_query_index_mark = (fun uu____1092 -> (

let uu____1093 = (FStar_ST.read query_indices)
in (match (uu____1093) with
| (hd)::(uu____1105)::tl -> begin
(FStar_ST.write query_indices ((hd)::tl))
end
| uu____1132 -> begin
(failwith "Unmarked query index stack")
end)))
in (

let stack = (FStar_Util.mk_ref [])
in (

let push_stack = (fun env -> ((let _0_165 = (let _0_164 = (FStar_ST.read stack)
in (env)::_0_164)
in (FStar_ST.write stack _0_165));
(

let uu___105_1153 = env
in (let _0_167 = (FStar_Util.smap_copy (gamma_cache env))
in (let _0_166 = (FStar_Util.smap_copy (sigtab env))
in {solver = uu___105_1153.solver; range = uu___105_1153.range; curmodule = uu___105_1153.curmodule; gamma = uu___105_1153.gamma; gamma_cache = _0_167; modules = uu___105_1153.modules; expected_typ = uu___105_1153.expected_typ; sigtab = _0_166; is_pattern = uu___105_1153.is_pattern; instantiate_imp = uu___105_1153.instantiate_imp; effects = uu___105_1153.effects; generalize = uu___105_1153.generalize; letrecs = uu___105_1153.letrecs; top_level = uu___105_1153.top_level; check_uvars = uu___105_1153.check_uvars; use_eq = uu___105_1153.use_eq; is_iface = uu___105_1153.is_iface; admit = uu___105_1153.admit; lax = uu___105_1153.lax; lax_universes = uu___105_1153.lax_universes; type_of = uu___105_1153.type_of; universe_of = uu___105_1153.universe_of; use_bv_sorts = uu___105_1153.use_bv_sorts; qname_and_index = uu___105_1153.qname_and_index})));
))
in (

let pop_stack = (fun env -> (

let uu____1158 = (FStar_ST.read stack)
in (match (uu____1158) with
| (env)::tl -> begin
((FStar_ST.write stack tl);
env;
)
end
| uu____1170 -> begin
(failwith "Impossible: Too many pops")
end)))
in (

let push = (fun env -> ((push_query_indices ());
(push_stack env);
))
in (

let pop = (fun env -> ((pop_query_indices ());
(pop_stack env);
))
in (

let mark = (fun env -> ((push_query_indices ());
(push_stack env);
))
in (

let commit_mark = (fun env -> ((commit_query_index_mark ());
(Prims.ignore (pop_stack env));
env;
))
in (

let reset_mark = (fun env -> ((pop_query_indices ());
(pop_stack env);
))
in (

let incr_query_index = (fun env -> (

let qix = (peek_query_indices ())
in (match (env.qname_and_index) with
| None -> begin
env
end
| Some (l, n) -> begin
(

let uu____1212 = (FStar_All.pipe_right qix (FStar_List.tryFind (fun uu____1224 -> (match (uu____1224) with
| (m, uu____1228) -> begin
(FStar_Ident.lid_equals l m)
end))))
in (match (uu____1212) with
| None -> begin
(

let next = (n + (Prims.parse_int "1"))
in ((add_query_index ((l), (next)));
(

let uu___106_1233 = env
in {solver = uu___106_1233.solver; range = uu___106_1233.range; curmodule = uu___106_1233.curmodule; gamma = uu___106_1233.gamma; gamma_cache = uu___106_1233.gamma_cache; modules = uu___106_1233.modules; expected_typ = uu___106_1233.expected_typ; sigtab = uu___106_1233.sigtab; is_pattern = uu___106_1233.is_pattern; instantiate_imp = uu___106_1233.instantiate_imp; effects = uu___106_1233.effects; generalize = uu___106_1233.generalize; letrecs = uu___106_1233.letrecs; top_level = uu___106_1233.top_level; check_uvars = uu___106_1233.check_uvars; use_eq = uu___106_1233.use_eq; is_iface = uu___106_1233.is_iface; admit = uu___106_1233.admit; lax = uu___106_1233.lax; lax_universes = uu___106_1233.lax_universes; type_of = uu___106_1233.type_of; universe_of = uu___106_1233.universe_of; use_bv_sorts = uu___106_1233.use_bv_sorts; qname_and_index = Some (((l), (next)))});
))
end
| Some (uu____1236, m) -> begin
(

let next = (m + (Prims.parse_int "1"))
in ((add_query_index ((l), (next)));
(

let uu___107_1242 = env
in {solver = uu___107_1242.solver; range = uu___107_1242.range; curmodule = uu___107_1242.curmodule; gamma = uu___107_1242.gamma; gamma_cache = uu___107_1242.gamma_cache; modules = uu___107_1242.modules; expected_typ = uu___107_1242.expected_typ; sigtab = uu___107_1242.sigtab; is_pattern = uu___107_1242.is_pattern; instantiate_imp = uu___107_1242.instantiate_imp; effects = uu___107_1242.effects; generalize = uu___107_1242.generalize; letrecs = uu___107_1242.letrecs; top_level = uu___107_1242.top_level; check_uvars = uu___107_1242.check_uvars; use_eq = uu___107_1242.use_eq; is_iface = uu___107_1242.is_iface; admit = uu___107_1242.admit; lax = uu___107_1242.lax; lax_universes = uu___107_1242.lax_universes; type_of = uu___107_1242.type_of; universe_of = uu___107_1242.universe_of; use_bv_sorts = uu___107_1242.use_bv_sorts; qname_and_index = Some (((l), (next)))});
))
end))
end)))
in {es_push = push; es_mark = push; es_reset_mark = pop; es_commit_mark = commit_mark; es_pop = pop; es_incr_query_index = incr_query_index})))))))))))))))


let push : env  ->  Prims.string  ->  env = (fun env msg -> ((env.solver.push msg);
(stack_ops.es_push env);
))


let mark : env  ->  env = (fun env -> ((env.solver.mark "USER MARK");
(stack_ops.es_mark env);
))


let commit_mark : env  ->  env = (fun env -> ((env.solver.commit_mark "USER MARK");
(stack_ops.es_commit_mark env);
))


let reset_mark : env  ->  env = (fun env -> ((env.solver.reset_mark "USER MARK");
(stack_ops.es_reset_mark env);
))


let pop : env  ->  Prims.string  ->  env = (fun env msg -> ((env.solver.pop msg);
(stack_ops.es_pop env);
))


let cleanup_interactive : env  ->  Prims.unit = (fun env -> (env.solver.pop ""))


let incr_query_index : env  ->  env = (fun env -> (stack_ops.es_incr_query_index env))


let debug : env  ->  FStar_Options.debug_level_t  ->  Prims.bool = (fun env l -> (FStar_Options.debug_at_level env.curmodule.FStar_Ident.str l))


let set_range : env  ->  FStar_Range.range  ->  env = (fun e r -> (match ((r = FStar_Range.dummyRange)) with
| true -> begin
e
end
| uu____1289 -> begin
(

let uu___108_1290 = e
in {solver = uu___108_1290.solver; range = r; curmodule = uu___108_1290.curmodule; gamma = uu___108_1290.gamma; gamma_cache = uu___108_1290.gamma_cache; modules = uu___108_1290.modules; expected_typ = uu___108_1290.expected_typ; sigtab = uu___108_1290.sigtab; is_pattern = uu___108_1290.is_pattern; instantiate_imp = uu___108_1290.instantiate_imp; effects = uu___108_1290.effects; generalize = uu___108_1290.generalize; letrecs = uu___108_1290.letrecs; top_level = uu___108_1290.top_level; check_uvars = uu___108_1290.check_uvars; use_eq = uu___108_1290.use_eq; is_iface = uu___108_1290.is_iface; admit = uu___108_1290.admit; lax = uu___108_1290.lax; lax_universes = uu___108_1290.lax_universes; type_of = uu___108_1290.type_of; universe_of = uu___108_1290.universe_of; use_bv_sorts = uu___108_1290.use_bv_sorts; qname_and_index = uu___108_1290.qname_and_index})
end))


let get_range : env  ->  FStar_Range.range = (fun e -> e.range)


let modules : env  ->  FStar_Syntax_Syntax.modul Prims.list = (fun env -> env.modules)


let current_module : env  ->  FStar_Ident.lident = (fun env -> env.curmodule)


let set_current_module : env  ->  FStar_Ident.lident  ->  env = (fun env lid -> (

let uu___109_1307 = env
in {solver = uu___109_1307.solver; range = uu___109_1307.range; curmodule = lid; gamma = uu___109_1307.gamma; gamma_cache = uu___109_1307.gamma_cache; modules = uu___109_1307.modules; expected_typ = uu___109_1307.expected_typ; sigtab = uu___109_1307.sigtab; is_pattern = uu___109_1307.is_pattern; instantiate_imp = uu___109_1307.instantiate_imp; effects = uu___109_1307.effects; generalize = uu___109_1307.generalize; letrecs = uu___109_1307.letrecs; top_level = uu___109_1307.top_level; check_uvars = uu___109_1307.check_uvars; use_eq = uu___109_1307.use_eq; is_iface = uu___109_1307.is_iface; admit = uu___109_1307.admit; lax = uu___109_1307.lax; lax_universes = uu___109_1307.lax_universes; type_of = uu___109_1307.type_of; universe_of = uu___109_1307.universe_of; use_bv_sorts = uu___109_1307.use_bv_sorts; qname_and_index = uu___109_1307.qname_and_index}))


let has_interface : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env l -> (FStar_All.pipe_right env.modules (FStar_Util.for_some (fun m -> (m.FStar_Syntax_Syntax.is_interface && (FStar_Ident.lid_equals m.FStar_Syntax_Syntax.name l))))))


let find_in_sigtab : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.sigelt Prims.option = (fun env lid -> (FStar_Util.smap_try_find (sigtab env) (FStar_Ident.text_of_lid lid)))


let name_not_found : FStar_Ident.lid  ->  Prims.string = (fun l -> (FStar_Util.format1 "Name \"%s\" not found" l.FStar_Ident.str))


let variable_not_found : FStar_Syntax_Syntax.bv  ->  Prims.string = (fun v -> (let _0_168 = (FStar_Syntax_Print.bv_to_string v)
in (FStar_Util.format1 "Variable \"%s\" not found" _0_168)))


let new_u_univ : Prims.unit  ->  FStar_Syntax_Syntax.universe = (fun uu____1331 -> FStar_Syntax_Syntax.U_unif ((FStar_Unionfind.fresh None)))


let inst_tscheme_with : FStar_Syntax_Syntax.tscheme  ->  FStar_Syntax_Syntax.universes  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.term) = (fun ts us -> (match (((ts), (us))) with
| (([], t), []) -> begin
(([]), (t))
end
| ((formals, t), uu____1352) -> begin
(

let n = ((FStar_List.length formals) - (Prims.parse_int "1"))
in (

let vs = (FStar_All.pipe_right us (FStar_List.mapi (fun i u -> FStar_Syntax_Syntax.UN ((((n - i)), (u))))))
in (let _0_169 = (FStar_Syntax_Subst.subst vs t)
in ((us), (_0_169)))))
end))


let inst_tscheme : FStar_Syntax_Syntax.tscheme  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.term) = (fun uu___92_1372 -> (match (uu___92_1372) with
| ([], t) -> begin
(([]), (t))
end
| (us, t) -> begin
(

let us' = (FStar_All.pipe_right us (FStar_List.map (fun uu____1386 -> (new_u_univ ()))))
in (inst_tscheme_with ((us), (t)) us'))
end))


let inst_tscheme_with_range : FStar_Range.range  ->  FStar_Syntax_Syntax.tscheme  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.term) = (fun r t -> (

let uu____1396 = (inst_tscheme t)
in (match (uu____1396) with
| (us, t) -> begin
(let _0_170 = (FStar_Syntax_Subst.set_use_range r t)
in ((us), (_0_170)))
end)))


let inst_effect_fun_with : FStar_Syntax_Syntax.universes  ->  env  ->  FStar_Syntax_Syntax.eff_decl  ->  FStar_Syntax_Syntax.tscheme  ->  FStar_Syntax_Syntax.term = (fun insts env ed uu____1414 -> (match (uu____1414) with
| (us, t) -> begin
(match (ed.FStar_Syntax_Syntax.binders) with
| [] -> begin
(

let univs = (FStar_List.append ed.FStar_Syntax_Syntax.univs us)
in ((match (((FStar_List.length insts) <> (FStar_List.length univs))) with
| true -> begin
(failwith (let _0_174 = (FStar_All.pipe_left FStar_Util.string_of_int (FStar_List.length univs))
in (let _0_173 = (FStar_All.pipe_left FStar_Util.string_of_int (FStar_List.length insts))
in (let _0_172 = (FStar_Syntax_Print.lid_to_string ed.FStar_Syntax_Syntax.mname)
in (let _0_171 = (FStar_Syntax_Print.term_to_string t)
in (FStar_Util.format4 "Expected %s instantiations; got %s; failed universe instantiation in effect %s\n\t%s\n" _0_174 _0_173 _0_172 _0_171))))))
end
| uu____1432 -> begin
()
end);
(Prims.snd (inst_tscheme_with (((FStar_List.append ed.FStar_Syntax_Syntax.univs us)), (t)) insts));
))
end
| uu____1434 -> begin
(failwith (let _0_175 = (FStar_Syntax_Print.lid_to_string ed.FStar_Syntax_Syntax.mname)
in (FStar_Util.format1 "Unexpected use of an uninstantiated effect: %s\n" _0_175)))
end)
end))

type tri =
| Yes
| No
| Maybe


let uu___is_Yes : tri  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Yes -> begin
true
end
| uu____1438 -> begin
false
end))


let uu___is_No : tri  ->  Prims.bool = (fun projectee -> (match (projectee) with
| No -> begin
true
end
| uu____1442 -> begin
false
end))


let uu___is_Maybe : tri  ->  Prims.bool = (fun projectee -> (match (projectee) with
| Maybe -> begin
true
end
| uu____1446 -> begin
false
end))


let in_cur_mod : env  ->  FStar_Ident.lident  ->  tri = (fun env l -> (

let cur = (current_module env)
in (match ((l.FStar_Ident.nsstr = cur.FStar_Ident.str)) with
| true -> begin
Yes
end
| uu____1454 -> begin
(match ((FStar_Util.starts_with l.FStar_Ident.nsstr cur.FStar_Ident.str)) with
| true -> begin
(

let lns = (FStar_List.append l.FStar_Ident.ns ((l.FStar_Ident.ident)::[]))
in (

let cur = (FStar_List.append cur.FStar_Ident.ns ((cur.FStar_Ident.ident)::[]))
in (

let rec aux = (fun c l -> (match (((c), (l))) with
| ([], uu____1472) -> begin
Maybe
end
| (uu____1476, []) -> begin
No
end
| ((hd)::tl, (hd')::tl') when (hd.FStar_Ident.idText = hd'.FStar_Ident.idText) -> begin
(aux tl tl')
end
| uu____1488 -> begin
No
end))
in (aux cur lns))))
end
| uu____1493 -> begin
No
end)
end)))


let lookup_qname : env  ->  FStar_Ident.lident  ->  ((FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ), (FStar_Syntax_Syntax.sigelt * FStar_Syntax_Syntax.universes Prims.option)) FStar_Util.either Prims.option = (fun env lid -> (

let cur_mod = (in_cur_mod env lid)
in (

let cache = (fun t -> ((FStar_Util.smap_add (gamma_cache env) lid.FStar_Ident.str t);
Some (t);
))
in (

let found = (match ((cur_mod <> No)) with
| true -> begin
(

let uu____1540 = (FStar_Util.smap_try_find (gamma_cache env) lid.FStar_Ident.str)
in (match (uu____1540) with
| None -> begin
(FStar_Util.find_map env.gamma (fun uu___93_1557 -> (match (uu___93_1557) with
| Binding_lid (l, t) -> begin
(match ((FStar_Ident.lid_equals lid l)) with
| true -> begin
Some (FStar_Util.Inl ((inst_tscheme t)))
end
| uu____1588 -> begin
None
end)
end
| Binding_sig (uu____1596, FStar_Syntax_Syntax.Sig_bundle (ses, uu____1598, uu____1599, uu____1600)) -> begin
(FStar_Util.find_map ses (fun se -> (

let uu____1610 = (FStar_All.pipe_right (FStar_Syntax_Util.lids_of_sigelt se) (FStar_Util.for_some (FStar_Ident.lid_equals lid)))
in (match (uu____1610) with
| true -> begin
(cache (FStar_Util.Inr (((se), (None)))))
end
| uu____1619 -> begin
None
end))))
end
| Binding_sig (lids, s) -> begin
(

let maybe_cache = (fun t -> (match (s) with
| FStar_Syntax_Syntax.Sig_declare_typ (uu____1630) -> begin
Some (t)
end
| uu____1637 -> begin
(cache t)
end))
in (

let uu____1638 = (FStar_All.pipe_right lids (FStar_Util.for_some (FStar_Ident.lid_equals lid)))
in (match (uu____1638) with
| true -> begin
(maybe_cache (FStar_Util.Inr (((s), (None)))))
end
| uu____1654 -> begin
None
end)))
end
| Binding_sig_inst (lids, s, us) -> begin
(

let uu____1667 = (FStar_All.pipe_right lids (FStar_Util.for_some (FStar_Ident.lid_equals lid)))
in (match (uu____1667) with
| true -> begin
Some (FStar_Util.Inr (((s), (Some (us)))))
end
| uu____1690 -> begin
None
end))
end
| uu____1698 -> begin
None
end)))
end
| se -> begin
se
end))
end
| uu____1708 -> begin
None
end)
in (match ((FStar_Util.is_some found)) with
| true -> begin
found
end
| uu____1731 -> begin
(

let uu____1732 = ((cur_mod <> Yes) || (has_interface env env.curmodule))
in (match (uu____1732) with
| true -> begin
(

let uu____1741 = (find_in_sigtab env lid)
in (match (uu____1741) with
| Some (se) -> begin
Some (FStar_Util.Inr (((se), (None))))
end
| None -> begin
None
end))
end
| uu____1772 -> begin
None
end))
end)))))


let rec add_sigelt : env  ->  FStar_Syntax_Syntax.sigelt  ->  Prims.unit = (fun env se -> (match (se) with
| FStar_Syntax_Syntax.Sig_bundle (ses, uu____1792, uu____1793, uu____1794) -> begin
(add_sigelts env ses)
end
| uu____1801 -> begin
(

let lids = (FStar_Syntax_Util.lids_of_sigelt se)
in ((FStar_List.iter (fun l -> (FStar_Util.smap_add (sigtab env) l.FStar_Ident.str se)) lids);
(match (se) with
| FStar_Syntax_Syntax.Sig_new_effect (ne, uu____1807) -> begin
(FStar_All.pipe_right ne.FStar_Syntax_Syntax.actions (FStar_List.iter (fun a -> (

let se_let = (FStar_Syntax_Util.action_as_lb ne.FStar_Syntax_Syntax.mname a)
in (FStar_Util.smap_add (sigtab env) a.FStar_Syntax_Syntax.action_name.FStar_Ident.str se_let)))))
end
| uu____1811 -> begin
()
end);
))
end))
and add_sigelts : env  ->  FStar_Syntax_Syntax.sigelt Prims.list  ->  Prims.unit = (fun env ses -> (FStar_All.pipe_right ses (FStar_List.iter (add_sigelt env))))


let try_lookup_bv : env  ->  FStar_Syntax_Syntax.bv  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax Prims.option = (fun env bv -> (FStar_Util.find_map env.gamma (fun uu___94_1827 -> (match (uu___94_1827) with
| Binding_var (id) when (FStar_Syntax_Syntax.bv_eq id bv) -> begin
Some (id.FStar_Syntax_Syntax.sort)
end
| uu____1834 -> begin
None
end))))


let lookup_type_of_let : FStar_Syntax_Syntax.sigelt  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.term) Prims.option = (fun se lid -> (match (se) with
| FStar_Syntax_Syntax.Sig_let ((uu____1849, (lb)::[]), uu____1851, uu____1852, uu____1853, uu____1854) -> begin
Some ((inst_tscheme ((lb.FStar_Syntax_Syntax.lbunivs), (lb.FStar_Syntax_Syntax.lbtyp))))
end
| FStar_Syntax_Syntax.Sig_let ((uu____1870, lbs), uu____1872, uu____1873, uu____1874, uu____1875) -> begin
(FStar_Util.find_map lbs (fun lb -> (match (lb.FStar_Syntax_Syntax.lbname) with
| FStar_Util.Inl (uu____1893) -> begin
(failwith "impossible")
end
| FStar_Util.Inr (fv) -> begin
(

let uu____1898 = (FStar_Syntax_Syntax.fv_eq_lid fv lid)
in (match (uu____1898) with
| true -> begin
Some ((inst_tscheme ((lb.FStar_Syntax_Syntax.lbunivs), (lb.FStar_Syntax_Syntax.lbtyp))))
end
| uu____1907 -> begin
None
end))
end)))
end
| uu____1910 -> begin
None
end))


let effect_signature : FStar_Syntax_Syntax.sigelt  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.term) Prims.option = (fun se -> (match (se) with
| FStar_Syntax_Syntax.Sig_new_effect (ne, uu____1923) -> begin
Some ((inst_tscheme (let _0_177 = (let _0_176 = (FStar_Syntax_Syntax.mk_Total ne.FStar_Syntax_Syntax.signature)
in (FStar_Syntax_Util.arrow ne.FStar_Syntax_Syntax.binders _0_176))
in ((ne.FStar_Syntax_Syntax.univs), (_0_177)))))
end
| FStar_Syntax_Syntax.Sig_effect_abbrev (lid, us, binders, uu____1931, uu____1932, uu____1933, uu____1934) -> begin
Some ((inst_tscheme (let _0_179 = (let _0_178 = (FStar_Syntax_Syntax.mk_Total FStar_Syntax_Syntax.teff)
in (FStar_Syntax_Util.arrow binders _0_178))
in ((us), (_0_179)))))
end
| uu____1943 -> begin
None
end))


let try_lookup_lid_aux : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax) Prims.option = (fun env lid -> (

let mapper = (fun uu___95_1970 -> (match (uu___95_1970) with
| FStar_Util.Inl (t) -> begin
Some (t)
end
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_datacon (uu____1991, uvs, t, uu____1994, uu____1995, uu____1996, uu____1997, uu____1998), None) -> begin
Some ((inst_tscheme ((uvs), (t))))
end
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_declare_typ (l, uvs, t, qs, uu____2015), None) -> begin
(

let uu____2024 = (let _0_180 = (in_cur_mod env l)
in (_0_180 = Yes))
in (match (uu____2024) with
| true -> begin
(

let uu____2028 = ((FStar_All.pipe_right qs (FStar_List.contains FStar_Syntax_Syntax.Assumption)) || env.is_iface)
in (match (uu____2028) with
| true -> begin
Some ((inst_tscheme ((uvs), (t))))
end
| uu____2035 -> begin
None
end))
end
| uu____2038 -> begin
Some ((inst_tscheme ((uvs), (t))))
end))
end
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (lid, uvs, tps, k, uu____2045, uu____2046, uu____2047, uu____2048), None) -> begin
(match (tps) with
| [] -> begin
(let _0_182 = (inst_tscheme ((uvs), (k)))
in (FStar_All.pipe_left (fun _0_181 -> Some (_0_181)) _0_182))
end
| uu____2073 -> begin
(let _0_186 = (inst_tscheme (let _0_185 = (let _0_184 = (FStar_Syntax_Syntax.mk_Total k)
in (FStar_Syntax_Util.flat_arrow tps _0_184))
in ((uvs), (_0_185))))
in (FStar_All.pipe_left (fun _0_183 -> Some (_0_183)) _0_186))
end)
end
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (lid, uvs, tps, k, uu____2087, uu____2088, uu____2089, uu____2090), Some (us)) -> begin
(match (tps) with
| [] -> begin
(let _0_188 = (inst_tscheme_with ((uvs), (k)) us)
in (FStar_All.pipe_left (fun _0_187 -> Some (_0_187)) _0_188))
end
| uu____2116 -> begin
(let _0_193 = (let _0_192 = (let _0_191 = (let _0_190 = (FStar_Syntax_Syntax.mk_Total k)
in (FStar_Syntax_Util.flat_arrow tps _0_190))
in ((uvs), (_0_191)))
in (inst_tscheme_with _0_192 us))
in (FStar_All.pipe_left (fun _0_189 -> Some (_0_189)) _0_193))
end)
end
| FStar_Util.Inr (se) -> begin
(match (se) with
| (FStar_Syntax_Syntax.Sig_let (uu____2138), None) -> begin
(lookup_type_of_let (Prims.fst se) lid)
end
| uu____2149 -> begin
(effect_signature (Prims.fst se))
end)
end))
in (

let uu____2154 = (let _0_194 = (lookup_qname env lid)
in (FStar_Util.bind_opt _0_194 mapper))
in (match (uu____2154) with
| Some (us, t) -> begin
Some (((us), ((

let uu___110_2182 = t
in {FStar_Syntax_Syntax.n = uu___110_2182.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = uu___110_2182.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = (FStar_Ident.range_of_lid lid); FStar_Syntax_Syntax.vars = uu___110_2182.FStar_Syntax_Syntax.vars}))))
end
| None -> begin
None
end))))


let lid_exists : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env l -> (

let uu____2199 = (lookup_qname env l)
in (match (uu____2199) with
| None -> begin
false
end
| Some (uu____2215) -> begin
true
end)))


let lookup_bv : env  ->  FStar_Syntax_Syntax.bv  ->  FStar_Syntax_Syntax.typ = (fun env bv -> (

let uu____2236 = (try_lookup_bv env bv)
in (match (uu____2236) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_196 = (variable_not_found bv)
in (let _0_195 = (FStar_Syntax_Syntax.range_of_bv bv)
in ((_0_196), (_0_195)))))))
end
| Some (t) -> begin
(let _0_197 = (FStar_Syntax_Syntax.range_of_bv bv)
in (FStar_Syntax_Subst.set_use_range _0_197 t))
end)))


let try_lookup_lid : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ) Prims.option = (fun env l -> (

let uu____2256 = (try_lookup_lid_aux env l)
in (match (uu____2256) with
| None -> begin
None
end
| Some (us, t) -> begin
Some ((let _0_198 = (FStar_Syntax_Subst.set_use_range (FStar_Ident.range_of_lid l) t)
in ((us), (_0_198))))
end)))


let lookup_lid : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ) = (fun env l -> (

let uu____2291 = (try_lookup_lid env l)
in (match (uu____2291) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_199 = (name_not_found l)
in ((_0_199), ((FStar_Ident.range_of_lid l)))))))
end
| Some (us, t) -> begin
((us), (t))
end)))


let lookup_univ : env  ->  FStar_Syntax_Syntax.univ_name  ->  Prims.bool = (fun env x -> (FStar_All.pipe_right (FStar_List.find (fun uu___96_2312 -> (match (uu___96_2312) with
| Binding_univ (y) -> begin
(x.FStar_Ident.idText = y.FStar_Ident.idText)
end
| uu____2314 -> begin
false
end)) env.gamma) FStar_Option.isSome))


let try_lookup_val_decl : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.tscheme * FStar_Syntax_Syntax.qualifier Prims.list) Prims.option = (fun env lid -> (

let uu____2325 = (lookup_qname env lid)
in (match (uu____2325) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_declare_typ (uu____2338, uvs, t, q, uu____2342), None)) -> begin
Some ((let _0_201 = (let _0_200 = (FStar_Syntax_Subst.set_use_range (FStar_Ident.range_of_lid lid) t)
in ((uvs), (_0_200)))
in ((_0_201), (q))))
end
| uu____2366 -> begin
None
end)))


let lookup_val_decl : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ) = (fun env lid -> (

let uu____2386 = (lookup_qname env lid)
in (match (uu____2386) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_declare_typ (uu____2397, uvs, t, uu____2400, uu____2401), None)) -> begin
(inst_tscheme_with_range (FStar_Ident.range_of_lid lid) ((uvs), (t)))
end
| uu____2417 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_202 = (name_not_found lid)
in ((_0_202), ((FStar_Ident.range_of_lid lid)))))))
end)))


let lookup_datacon : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.universes * FStar_Syntax_Syntax.typ) = (fun env lid -> (

let uu____2436 = (lookup_qname env lid)
in (match (uu____2436) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_datacon (uu____2447, uvs, t, uu____2450, uu____2451, uu____2452, uu____2453, uu____2454), None)) -> begin
(inst_tscheme_with_range (FStar_Ident.range_of_lid lid) ((uvs), (t)))
end
| uu____2472 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_203 = (name_not_found lid)
in ((_0_203), ((FStar_Ident.range_of_lid lid)))))))
end)))


let datacons_of_typ : env  ->  FStar_Ident.lident  ->  (Prims.bool * FStar_Ident.lident Prims.list) = (fun env lid -> (

let uu____2492 = (lookup_qname env lid)
in (match (uu____2492) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (uu____2504, uu____2505, uu____2506, uu____2507, uu____2508, dcs, uu____2510, uu____2511), uu____2512)) -> begin
((true), (dcs))
end
| uu____2534 -> begin
((false), ([]))
end)))


let typ_of_datacon : env  ->  FStar_Ident.lident  ->  FStar_Ident.lident = (fun env lid -> (

let uu____2550 = (lookup_qname env lid)
in (match (uu____2550) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_datacon (uu____2559, uu____2560, uu____2561, l, uu____2563, uu____2564, uu____2565, uu____2566), uu____2567)) -> begin
l
end
| uu____2586 -> begin
(failwith (let _0_204 = (FStar_Syntax_Print.lid_to_string lid)
in (FStar_Util.format1 "Not a datacon: %s" _0_204)))
end)))


let lookup_definition : delta_level Prims.list  ->  env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.univ_names * FStar_Syntax_Syntax.term) Prims.option = (fun delta_levels env lid -> (

let visible = (fun quals -> (FStar_All.pipe_right delta_levels (FStar_Util.for_some (fun dl -> (FStar_All.pipe_right quals (FStar_Util.for_some (visible_at dl)))))))
in (

let uu____2618 = (lookup_qname env lid)
in (match (uu____2618) with
| Some (FStar_Util.Inr (se, None)) -> begin
(match (se) with
| FStar_Syntax_Syntax.Sig_let ((uu____2647, lbs), uu____2649, uu____2650, quals, uu____2652) when (visible quals) -> begin
(FStar_Util.find_map lbs (fun lb -> (

let fv = (FStar_Util.right lb.FStar_Syntax_Syntax.lbname)
in (

let uu____2669 = (FStar_Syntax_Syntax.fv_eq_lid fv lid)
in (match (uu____2669) with
| true -> begin
Some ((let _0_206 = (let _0_205 = (FStar_Syntax_Util.unascribe lb.FStar_Syntax_Syntax.lbdef)
in (FStar_Syntax_Subst.set_use_range (FStar_Ident.range_of_lid lid) _0_205))
in ((lb.FStar_Syntax_Syntax.lbunivs), (_0_206))))
end
| uu____2678 -> begin
None
end)))))
end
| uu____2682 -> begin
None
end)
end
| uu____2685 -> begin
None
end))))


let try_lookup_effect_lid : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.term Prims.option = (fun env ftv -> (

let uu____2704 = (lookup_qname env ftv)
in (match (uu____2704) with
| Some (FStar_Util.Inr (se, None)) -> begin
(

let uu____2728 = (effect_signature se)
in (match (uu____2728) with
| None -> begin
None
end
| Some (uu____2735, t) -> begin
Some ((FStar_Syntax_Subst.set_use_range (FStar_Ident.range_of_lid ftv) t))
end))
end
| uu____2739 -> begin
None
end)))


let lookup_effect_lid : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.term = (fun env ftv -> (

let uu____2754 = (try_lookup_effect_lid env ftv)
in (match (uu____2754) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_207 = (name_not_found ftv)
in ((_0_207), ((FStar_Ident.range_of_lid ftv)))))))
end
| Some (k) -> begin
k
end)))


let lookup_effect_abbrev : env  ->  FStar_Syntax_Syntax.universes  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.binders * FStar_Syntax_Syntax.comp) Prims.option = (fun env univ_insts lid0 -> (

let uu____2769 = (lookup_qname env lid0)
in (match (uu____2769) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_effect_abbrev (lid, univs, binders, c, quals, uu____2786, uu____2787), None)) -> begin
(

let lid = (let _0_208 = (FStar_Range.set_use_range (FStar_Ident.range_of_lid lid) (FStar_Ident.range_of_lid lid0))
in (FStar_Ident.set_lid_range lid _0_208))
in (

let uu____2806 = (FStar_All.pipe_right quals (FStar_Util.for_some (fun uu___97_2808 -> (match (uu___97_2808) with
| FStar_Syntax_Syntax.Irreducible -> begin
true
end
| uu____2809 -> begin
false
end))))
in (match (uu____2806) with
| true -> begin
None
end
| uu____2815 -> begin
(

let insts = (match (((FStar_List.length univ_insts) = (FStar_List.length univs))) with
| true -> begin
univ_insts
end
| uu____2821 -> begin
(match (((FStar_Ident.lid_equals lid FStar_Syntax_Const.effect_Lemma_lid) && ((FStar_List.length univ_insts) = (Prims.parse_int "1")))) with
| true -> begin
(FStar_List.append univ_insts ((FStar_Syntax_Syntax.U_zero)::[]))
end
| uu____2824 -> begin
(failwith (let _0_210 = (FStar_Syntax_Print.lid_to_string lid)
in (let _0_209 = (FStar_All.pipe_right (FStar_List.length univ_insts) FStar_Util.string_of_int)
in (FStar_Util.format2 "Unexpected instantiation of effect %s with %s universes" _0_210 _0_209))))
end)
end)
in (match (((binders), (univs))) with
| ([], uu____2830) -> begin
(failwith "Unexpected effect abbreviation with no arguments")
end
| (uu____2839, (uu____2840)::(uu____2841)::uu____2842) when (not ((FStar_Ident.lid_equals lid FStar_Syntax_Const.effect_Lemma_lid))) -> begin
(failwith (let _0_212 = (FStar_Syntax_Print.lid_to_string lid)
in (let _0_211 = (FStar_All.pipe_left FStar_Util.string_of_int (FStar_List.length univs))
in (FStar_Util.format2 "Unexpected effect abbreviation %s; polymorphic in %s universes" _0_212 _0_211))))
end
| uu____2850 -> begin
(

let uu____2853 = (let _0_214 = (let _0_213 = (FStar_Syntax_Util.arrow binders c)
in ((univs), (_0_213)))
in (inst_tscheme_with _0_214 insts))
in (match (uu____2853) with
| (uu____2861, t) -> begin
(

let t = (FStar_Syntax_Subst.set_use_range (FStar_Ident.range_of_lid lid) t)
in (

let uu____2864 = (FStar_Syntax_Subst.compress t).FStar_Syntax_Syntax.n
in (match (uu____2864) with
| FStar_Syntax_Syntax.Tm_arrow (binders, c) -> begin
Some (((binders), (c)))
end
| uu____2892 -> begin
(failwith "Impossible")
end)))
end))
end))
end)))
end
| uu____2896 -> begin
None
end)))


let norm_eff_name : env  ->  FStar_Ident.lident  ->  FStar_Ident.lident = (

let cache = (FStar_Util.smap_create (Prims.parse_int "20"))
in (fun env l -> (

let rec find = (fun l -> (

let uu____2920 = (lookup_effect_abbrev env ((FStar_Syntax_Syntax.U_unknown)::[]) l)
in (match (uu____2920) with
| None -> begin
None
end
| Some (uu____2927, c) -> begin
(

let l = (FStar_Syntax_Util.comp_effect_name c)
in (

let uu____2932 = (find l)
in (match (uu____2932) with
| None -> begin
Some (l)
end
| Some (l') -> begin
Some (l')
end)))
end)))
in (

let res = (

let uu____2937 = (FStar_Util.smap_try_find cache l.FStar_Ident.str)
in (match (uu____2937) with
| Some (l) -> begin
l
end
| None -> begin
(

let uu____2940 = (find l)
in (match (uu____2940) with
| None -> begin
l
end
| Some (m) -> begin
((FStar_Util.smap_add cache l.FStar_Ident.str m);
m;
)
end))
end))
in (FStar_Ident.set_lid_range res (FStar_Ident.range_of_lid l))))))


let lookup_effect_quals : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.qualifier Prims.list = (fun env l -> (

let l = (norm_eff_name env l)
in (

let uu____2952 = (lookup_qname env l)
in (match (uu____2952) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_new_effect (ne, uu____2963), uu____2964)) -> begin
ne.FStar_Syntax_Syntax.qualifiers
end
| uu____2979 -> begin
[]
end))))


let lookup_projector : env  ->  FStar_Ident.lident  ->  Prims.int  ->  FStar_Ident.lident = (fun env lid i -> (

let fail = (fun uu____3000 -> (failwith (let _0_216 = (FStar_Util.string_of_int i)
in (let _0_215 = (FStar_Syntax_Print.lid_to_string lid)
in (FStar_Util.format2 "Impossible: projecting field #%s from constructor %s is undefined" _0_216 _0_215)))))
in (

let uu____3001 = (lookup_datacon env lid)
in (match (uu____3001) with
| (uu____3004, t) -> begin
(

let uu____3006 = (FStar_Syntax_Subst.compress t).FStar_Syntax_Syntax.n
in (match (uu____3006) with
| FStar_Syntax_Syntax.Tm_arrow (binders, uu____3008) -> begin
(match (((i < (Prims.parse_int "0")) || (i >= (FStar_List.length binders)))) with
| true -> begin
(fail ())
end
| uu____3023 -> begin
(

let b = (FStar_List.nth binders i)
in (let _0_217 = (FStar_Syntax_Util.mk_field_projector_name lid (Prims.fst b) i)
in (FStar_All.pipe_right _0_217 Prims.fst)))
end)
end
| uu____3031 -> begin
(fail ())
end))
end))))


let is_projector : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env l -> (

let uu____3038 = (lookup_qname env l)
in (match (uu____3038) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_declare_typ (uu____3047, uu____3048, uu____3049, quals, uu____3051), uu____3052)) -> begin
(FStar_Util.for_some (fun uu___98_3069 -> (match (uu___98_3069) with
| FStar_Syntax_Syntax.Projector (uu____3070) -> begin
true
end
| uu____3073 -> begin
false
end)) quals)
end
| uu____3074 -> begin
false
end)))


let is_datacon : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env lid -> (

let uu____3089 = (lookup_qname env lid)
in (match (uu____3089) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_datacon (uu____3098, uu____3099, uu____3100, uu____3101, uu____3102, uu____3103, uu____3104, uu____3105), uu____3106)) -> begin
true
end
| uu____3125 -> begin
false
end)))


let is_record : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env lid -> (

let uu____3140 = (lookup_qname env lid)
in (match (uu____3140) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (uu____3149, uu____3150, uu____3151, uu____3152, uu____3153, uu____3154, tags, uu____3156), uu____3157)) -> begin
(FStar_Util.for_some (fun uu___99_3178 -> (match (uu___99_3178) with
| (FStar_Syntax_Syntax.RecordType (_)) | (FStar_Syntax_Syntax.RecordConstructor (_)) -> begin
true
end
| uu____3181 -> begin
false
end)) tags)
end
| uu____3182 -> begin
false
end)))


let is_action : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env lid -> (

let uu____3197 = (lookup_qname env lid)
in (match (uu____3197) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_let (uu____3206, uu____3207, uu____3208, tags, uu____3210), uu____3211)) -> begin
(FStar_Util.for_some (fun uu___100_3232 -> (match (uu___100_3232) with
| FStar_Syntax_Syntax.Action (uu____3233) -> begin
true
end
| uu____3234 -> begin
false
end)) tags)
end
| uu____3235 -> begin
false
end)))


let is_interpreted : env  ->  FStar_Syntax_Syntax.term  ->  Prims.bool = (

let interpreted_symbols = (FStar_Syntax_Const.op_Eq)::(FStar_Syntax_Const.op_notEq)::(FStar_Syntax_Const.op_LT)::(FStar_Syntax_Const.op_LTE)::(FStar_Syntax_Const.op_GT)::(FStar_Syntax_Const.op_GTE)::(FStar_Syntax_Const.op_Subtraction)::(FStar_Syntax_Const.op_Minus)::(FStar_Syntax_Const.op_Addition)::(FStar_Syntax_Const.op_Multiply)::(FStar_Syntax_Const.op_Division)::(FStar_Syntax_Const.op_Modulus)::(FStar_Syntax_Const.op_And)::(FStar_Syntax_Const.op_Or)::(FStar_Syntax_Const.op_Negation)::[]
in (fun env head -> (

let uu____3252 = (FStar_Syntax_Util.un_uinst head).FStar_Syntax_Syntax.n
in (match (uu____3252) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
(fv.FStar_Syntax_Syntax.fv_delta = FStar_Syntax_Syntax.Delta_equational)
end
| uu____3254 -> begin
false
end))))


let is_type_constructor : env  ->  FStar_Ident.lident  ->  Prims.bool = (fun env lid -> (

let mapper = (fun uu___101_3272 -> (match (uu___101_3272) with
| FStar_Util.Inl (uu____3281) -> begin
Some (false)
end
| FStar_Util.Inr (se, uu____3290) -> begin
(match (se) with
| FStar_Syntax_Syntax.Sig_declare_typ (uu____3299, uu____3300, uu____3301, qs, uu____3303) -> begin
Some ((FStar_List.contains FStar_Syntax_Syntax.New qs))
end
| FStar_Syntax_Syntax.Sig_inductive_typ (uu____3306) -> begin
Some (true)
end
| uu____3318 -> begin
Some (false)
end)
end))
in (

let uu____3319 = (let _0_218 = (lookup_qname env lid)
in (FStar_Util.bind_opt _0_218 mapper))
in (match (uu____3319) with
| Some (b) -> begin
b
end
| None -> begin
false
end))))


let num_inductive_ty_params : env  ->  FStar_Ident.lident  ->  Prims.int = (fun env lid -> (

let uu____3335 = (lookup_qname env lid)
in (match (uu____3335) with
| Some (FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (uu____3344, uu____3345, tps, uu____3347, uu____3348, uu____3349, uu____3350, uu____3351), uu____3352)) -> begin
(FStar_List.length tps)
end
| uu____3376 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_219 = (name_not_found lid)
in ((_0_219), ((FStar_Ident.range_of_lid lid)))))))
end)))


let effect_decl_opt : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.eff_decl Prims.option = (fun env l -> (FStar_All.pipe_right env.effects.decls (FStar_Util.find_opt (fun d -> (FStar_Ident.lid_equals d.FStar_Syntax_Syntax.mname l)))))


let get_effect_decl : env  ->  FStar_Ident.lident  ->  FStar_Syntax_Syntax.eff_decl = (fun env l -> (

let uu____3401 = (effect_decl_opt env l)
in (match (uu____3401) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_220 = (name_not_found l)
in ((_0_220), ((FStar_Ident.range_of_lid l)))))))
end
| Some (md) -> begin
md
end)))


let join : env  ->  FStar_Ident.lident  ->  FStar_Ident.lident  ->  (FStar_Ident.lident * mlift * mlift) = (fun env l1 l2 -> (match ((FStar_Ident.lid_equals l1 l2)) with
| true -> begin
((l1), ((fun t wp -> wp)), ((fun t wp -> wp)))
end
| uu____3450 -> begin
(match ((((FStar_Ident.lid_equals l1 FStar_Syntax_Const.effect_GTot_lid) && (FStar_Ident.lid_equals l2 FStar_Syntax_Const.effect_Tot_lid)) || ((FStar_Ident.lid_equals l2 FStar_Syntax_Const.effect_GTot_lid) && (FStar_Ident.lid_equals l1 FStar_Syntax_Const.effect_Tot_lid)))) with
| true -> begin
((FStar_Syntax_Const.effect_GTot_lid), ((fun t wp -> wp)), ((fun t wp -> wp)))
end
| uu____3474 -> begin
(

let uu____3475 = (FStar_All.pipe_right env.effects.joins (FStar_Util.find_opt (fun uu____3499 -> (match (uu____3499) with
| (m1, m2, uu____3507, uu____3508, uu____3509) -> begin
((FStar_Ident.lid_equals l1 m1) && (FStar_Ident.lid_equals l2 m2))
end))))
in (match (uu____3475) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_223 = (let _0_222 = (FStar_Syntax_Print.lid_to_string l1)
in (let _0_221 = (FStar_Syntax_Print.lid_to_string l2)
in (FStar_Util.format2 "Effects %s and %s cannot be composed" _0_222 _0_221)))
in ((_0_223), (env.range))))))
end
| Some (uu____3537, uu____3538, m3, j1, j2) -> begin
((m3), (j1), (j2))
end))
end)
end))


let monad_leq : env  ->  FStar_Ident.lident  ->  FStar_Ident.lident  ->  edge Prims.option = (fun env l1 l2 -> (match (((FStar_Ident.lid_equals l1 l2) || ((FStar_Ident.lid_equals l1 FStar_Syntax_Const.effect_Tot_lid) && (FStar_Ident.lid_equals l2 FStar_Syntax_Const.effect_GTot_lid)))) with
| true -> begin
Some ({msource = l1; mtarget = l2; mlift = (fun t wp -> wp)})
end
| uu____3569 -> begin
(FStar_All.pipe_right env.effects.order (FStar_Util.find_opt (fun e -> ((FStar_Ident.lid_equals l1 e.msource) && (FStar_Ident.lid_equals l2 e.mtarget)))))
end))


let wp_sig_aux : FStar_Syntax_Syntax.eff_decl Prims.list  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.bv * (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax) = (fun decls m -> (

let uu____3585 = (FStar_All.pipe_right decls (FStar_Util.find_opt (fun d -> (FStar_Ident.lid_equals d.FStar_Syntax_Syntax.mname m))))
in (match (uu____3585) with
| None -> begin
(failwith (FStar_Util.format1 "Impossible: declaration for monad %s not found" m.FStar_Ident.str))
end
| Some (md) -> begin
(

let uu____3599 = (inst_tscheme ((md.FStar_Syntax_Syntax.univs), (md.FStar_Syntax_Syntax.signature)))
in (match (uu____3599) with
| (uu____3606, s) -> begin
(

let s = (FStar_Syntax_Subst.compress s)
in (match (((md.FStar_Syntax_Syntax.binders), (s.FStar_Syntax_Syntax.n))) with
| ([], FStar_Syntax_Syntax.Tm_arrow (((a, uu____3614))::((wp, uu____3616))::[], c)) when (FStar_Syntax_Syntax.is_teff (FStar_Syntax_Util.comp_result c)) -> begin
((a), (wp.FStar_Syntax_Syntax.sort))
end
| uu____3638 -> begin
(failwith "Impossible")
end))
end))
end)))


let wp_signature : env  ->  FStar_Ident.lident  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term) = (fun env m -> (wp_sig_aux env.effects.decls m))


let build_lattice : env  ->  FStar_Syntax_Syntax.sigelt  ->  env = (fun env se -> (match (se) with
| FStar_Syntax_Syntax.Sig_new_effect (ne, uu____3660) -> begin
(

let effects = (

let uu___111_3662 = env.effects
in {decls = (ne)::env.effects.decls; order = uu___111_3662.order; joins = uu___111_3662.joins})
in (

let uu___112_3663 = env
in {solver = uu___112_3663.solver; range = uu___112_3663.range; curmodule = uu___112_3663.curmodule; gamma = uu___112_3663.gamma; gamma_cache = uu___112_3663.gamma_cache; modules = uu___112_3663.modules; expected_typ = uu___112_3663.expected_typ; sigtab = uu___112_3663.sigtab; is_pattern = uu___112_3663.is_pattern; instantiate_imp = uu___112_3663.instantiate_imp; effects = effects; generalize = uu___112_3663.generalize; letrecs = uu___112_3663.letrecs; top_level = uu___112_3663.top_level; check_uvars = uu___112_3663.check_uvars; use_eq = uu___112_3663.use_eq; is_iface = uu___112_3663.is_iface; admit = uu___112_3663.admit; lax = uu___112_3663.lax; lax_universes = uu___112_3663.lax_universes; type_of = uu___112_3663.type_of; universe_of = uu___112_3663.universe_of; use_bv_sorts = uu___112_3663.use_bv_sorts; qname_and_index = uu___112_3663.qname_and_index}))
end
| FStar_Syntax_Syntax.Sig_sub_effect (sub, uu____3665) -> begin
(

let compose_edges = (fun e1 e2 -> {msource = e1.msource; mtarget = e2.mtarget; mlift = (fun r wp1 -> (let _0_224 = (e1.mlift r wp1)
in (e2.mlift r _0_224)))})
in (

let mk_lift = (fun lift_t r wp1 -> (

let uu____3687 = (inst_tscheme lift_t)
in (match (uu____3687) with
| (uu____3692, lift_t) -> begin
((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app ((let _0_228 = (let _0_227 = (FStar_Syntax_Syntax.as_arg r)
in (let _0_226 = (let _0_225 = (FStar_Syntax_Syntax.as_arg wp1)
in (_0_225)::[])
in (_0_227)::_0_226))
in ((lift_t), (_0_228)))))) None wp1.FStar_Syntax_Syntax.pos)
end)))
in (

let sub_lift_wp = (match (sub.FStar_Syntax_Syntax.lift_wp) with
| Some (sub_lift_wp) -> begin
sub_lift_wp
end
| None -> begin
(failwith "sub effect should\'ve been elaborated at this stage")
end)
in (

let edge = {msource = sub.FStar_Syntax_Syntax.source; mtarget = sub.FStar_Syntax_Syntax.target; mlift = (mk_lift sub_lift_wp)}
in (

let id_edge = (fun l -> {msource = sub.FStar_Syntax_Syntax.source; mtarget = sub.FStar_Syntax_Syntax.target; mlift = (fun t wp -> wp)})
in (

let print_mlift = (fun l -> (

let arg = (let _0_229 = (FStar_Ident.lid_of_path (("ARG")::[]) FStar_Range.dummyRange)
in (FStar_Syntax_Syntax.lid_as_fv _0_229 FStar_Syntax_Syntax.Delta_constant None))
in (

let wp = (let _0_230 = (FStar_Ident.lid_of_path (("WP")::[]) FStar_Range.dummyRange)
in (FStar_Syntax_Syntax.lid_as_fv _0_230 FStar_Syntax_Syntax.Delta_constant None))
in (FStar_Syntax_Print.term_to_string (l arg wp)))))
in (

let order = (edge)::env.effects.order
in (

let ms = (FStar_All.pipe_right env.effects.decls (FStar_List.map (fun e -> e.FStar_Syntax_Syntax.mname)))
in (

let find_edge = (fun order uu____3745 -> (match (uu____3745) with
| (i, j) -> begin
(match ((FStar_Ident.lid_equals i j)) with
| true -> begin
(FStar_All.pipe_right (id_edge i) (fun _0_231 -> Some (_0_231)))
end
| uu____3754 -> begin
(FStar_All.pipe_right order (FStar_Util.find_opt (fun e -> ((FStar_Ident.lid_equals e.msource i) && (FStar_Ident.lid_equals e.mtarget j)))))
end)
end))
in (

let order = (FStar_All.pipe_right ms (FStar_List.fold_left (fun order k -> (let _0_234 = (FStar_All.pipe_right ms (FStar_List.collect (fun i -> (match ((FStar_Ident.lid_equals i k)) with
| true -> begin
[]
end
| uu____3770 -> begin
(FStar_All.pipe_right ms (FStar_List.collect (fun j -> (match ((FStar_Ident.lid_equals j k)) with
| true -> begin
[]
end
| uu____3775 -> begin
(

let uu____3776 = (let _0_233 = (find_edge order ((i), (k)))
in (let _0_232 = (find_edge order ((k), (j)))
in ((_0_233), (_0_232))))
in (match (uu____3776) with
| (Some (e1), Some (e2)) -> begin
((compose_edges e1 e2))::[]
end
| uu____3788 -> begin
[]
end))
end))))
end))))
in (FStar_List.append order _0_234))) order))
in (

let order = (FStar_Util.remove_dups (fun e1 e2 -> ((FStar_Ident.lid_equals e1.msource e2.msource) && (FStar_Ident.lid_equals e1.mtarget e2.mtarget))) order)
in ((FStar_All.pipe_right order (FStar_List.iter (fun edge -> (

let uu____3800 = ((FStar_Ident.lid_equals edge.msource FStar_Syntax_Const.effect_DIV_lid) && (let _0_235 = (lookup_effect_quals env edge.mtarget)
in (FStar_All.pipe_right _0_235 (FStar_List.contains FStar_Syntax_Syntax.TotalEffect))))
in (match (uu____3800) with
| true -> begin
(Prims.raise (FStar_Errors.Error ((let _0_237 = (FStar_Util.format1 "Divergent computations cannot be included in an effect %s marked \'total\'" edge.mtarget.FStar_Ident.str)
in (let _0_236 = (get_range env)
in ((_0_237), (_0_236)))))))
end
| uu____3802 -> begin
()
end)))));
(

let joins = (FStar_All.pipe_right ms (FStar_List.collect (fun i -> (FStar_All.pipe_right ms (FStar_List.collect (fun j -> (

let join_opt = (FStar_All.pipe_right ms (FStar_List.fold_left (fun bopt k -> (

let uu____3896 = (let _0_239 = (find_edge order ((i), (k)))
in (let _0_238 = (find_edge order ((j), (k)))
in ((_0_239), (_0_238))))
in (match (uu____3896) with
| (Some (ik), Some (jk)) -> begin
(match (bopt) with
| None -> begin
Some (((k), (ik), (jk)))
end
| Some (ub, uu____3922, uu____3923) -> begin
(

let uu____3927 = ((FStar_Util.is_some (find_edge order ((k), (ub)))) && (not ((FStar_Util.is_some (find_edge order ((ub), (k)))))))
in (match (uu____3927) with
| true -> begin
Some (((k), (ik), (jk)))
end
| uu____3935 -> begin
bopt
end))
end)
end
| uu____3936 -> begin
bopt
end))) None))
in (match (join_opt) with
| None -> begin
[]
end
| Some (k, e1, e2) -> begin
(((i), (j), (k), (e1.mlift), (e2.mlift)))::[]
end))))))))
in (

let effects = (

let uu___113_4015 = env.effects
in {decls = uu___113_4015.decls; order = order; joins = joins})
in (

let uu___114_4016 = env
in {solver = uu___114_4016.solver; range = uu___114_4016.range; curmodule = uu___114_4016.curmodule; gamma = uu___114_4016.gamma; gamma_cache = uu___114_4016.gamma_cache; modules = uu___114_4016.modules; expected_typ = uu___114_4016.expected_typ; sigtab = uu___114_4016.sigtab; is_pattern = uu___114_4016.is_pattern; instantiate_imp = uu___114_4016.instantiate_imp; effects = effects; generalize = uu___114_4016.generalize; letrecs = uu___114_4016.letrecs; top_level = uu___114_4016.top_level; check_uvars = uu___114_4016.check_uvars; use_eq = uu___114_4016.use_eq; is_iface = uu___114_4016.is_iface; admit = uu___114_4016.admit; lax = uu___114_4016.lax; lax_universes = uu___114_4016.lax_universes; type_of = uu___114_4016.type_of; universe_of = uu___114_4016.universe_of; use_bv_sorts = uu___114_4016.use_bv_sorts; qname_and_index = uu___114_4016.qname_and_index})));
))))))))))))
end
| uu____4017 -> begin
env
end))


let push_in_gamma : env  ->  binding  ->  env = (fun env s -> (

let rec push = (fun x rest -> (match (rest) with
| ((Binding_sig (_))::_) | ((Binding_sig_inst (_))::_) -> begin
(x)::rest
end
| [] -> begin
(x)::[]
end
| (local)::rest -> begin
(let _0_240 = (push x rest)
in (local)::_0_240)
end))
in (

let uu___115_4042 = env
in (let _0_241 = (push s env.gamma)
in {solver = uu___115_4042.solver; range = uu___115_4042.range; curmodule = uu___115_4042.curmodule; gamma = _0_241; gamma_cache = uu___115_4042.gamma_cache; modules = uu___115_4042.modules; expected_typ = uu___115_4042.expected_typ; sigtab = uu___115_4042.sigtab; is_pattern = uu___115_4042.is_pattern; instantiate_imp = uu___115_4042.instantiate_imp; effects = uu___115_4042.effects; generalize = uu___115_4042.generalize; letrecs = uu___115_4042.letrecs; top_level = uu___115_4042.top_level; check_uvars = uu___115_4042.check_uvars; use_eq = uu___115_4042.use_eq; is_iface = uu___115_4042.is_iface; admit = uu___115_4042.admit; lax = uu___115_4042.lax; lax_universes = uu___115_4042.lax_universes; type_of = uu___115_4042.type_of; universe_of = uu___115_4042.universe_of; use_bv_sorts = uu___115_4042.use_bv_sorts; qname_and_index = uu___115_4042.qname_and_index}))))


let push_sigelt : env  ->  FStar_Syntax_Syntax.sigelt  ->  env = (fun env s -> (

let env = (push_in_gamma env (Binding_sig ((((FStar_Syntax_Util.lids_of_sigelt s)), (s)))))
in (build_lattice env s)))


let push_sigelt_inst : env  ->  FStar_Syntax_Syntax.sigelt  ->  FStar_Syntax_Syntax.universes  ->  env = (fun env s us -> (

let env = (push_in_gamma env (Binding_sig_inst ((((FStar_Syntax_Util.lids_of_sigelt s)), (s), (us)))))
in (build_lattice env s)))


let push_local_binding : env  ->  binding  ->  env = (fun env b -> (

let uu___116_4068 = env
in {solver = uu___116_4068.solver; range = uu___116_4068.range; curmodule = uu___116_4068.curmodule; gamma = (b)::env.gamma; gamma_cache = uu___116_4068.gamma_cache; modules = uu___116_4068.modules; expected_typ = uu___116_4068.expected_typ; sigtab = uu___116_4068.sigtab; is_pattern = uu___116_4068.is_pattern; instantiate_imp = uu___116_4068.instantiate_imp; effects = uu___116_4068.effects; generalize = uu___116_4068.generalize; letrecs = uu___116_4068.letrecs; top_level = uu___116_4068.top_level; check_uvars = uu___116_4068.check_uvars; use_eq = uu___116_4068.use_eq; is_iface = uu___116_4068.is_iface; admit = uu___116_4068.admit; lax = uu___116_4068.lax; lax_universes = uu___116_4068.lax_universes; type_of = uu___116_4068.type_of; universe_of = uu___116_4068.universe_of; use_bv_sorts = uu___116_4068.use_bv_sorts; qname_and_index = uu___116_4068.qname_and_index}))


let push_bv : env  ->  FStar_Syntax_Syntax.bv  ->  env = (fun env x -> (push_local_binding env (Binding_var (x))))


let push_binders : env  ->  FStar_Syntax_Syntax.binders  ->  env = (fun env bs -> (FStar_List.fold_left (fun env uu____4084 -> (match (uu____4084) with
| (x, uu____4088) -> begin
(push_bv env x)
end)) env bs))


let binding_of_lb : FStar_Syntax_Syntax.lbname  ->  (FStar_Syntax_Syntax.univ_name Prims.list * (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax)  ->  binding = (fun x t -> (match (x) with
| FStar_Util.Inl (x) -> begin
(

let x = (

let uu___117_4108 = x
in {FStar_Syntax_Syntax.ppname = uu___117_4108.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___117_4108.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = (Prims.snd t)})
in Binding_var (x))
end
| FStar_Util.Inr (fv) -> begin
Binding_lid (((fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v), (t)))
end))


let push_let_binding : env  ->  FStar_Syntax_Syntax.lbname  ->  FStar_Syntax_Syntax.tscheme  ->  env = (fun env lb ts -> (push_local_binding env (binding_of_lb lb ts)))


let push_module : env  ->  FStar_Syntax_Syntax.modul  ->  env = (fun env m -> ((add_sigelts env m.FStar_Syntax_Syntax.exports);
(

let uu___118_4138 = env
in {solver = uu___118_4138.solver; range = uu___118_4138.range; curmodule = uu___118_4138.curmodule; gamma = []; gamma_cache = uu___118_4138.gamma_cache; modules = (m)::env.modules; expected_typ = None; sigtab = uu___118_4138.sigtab; is_pattern = uu___118_4138.is_pattern; instantiate_imp = uu___118_4138.instantiate_imp; effects = uu___118_4138.effects; generalize = uu___118_4138.generalize; letrecs = uu___118_4138.letrecs; top_level = uu___118_4138.top_level; check_uvars = uu___118_4138.check_uvars; use_eq = uu___118_4138.use_eq; is_iface = uu___118_4138.is_iface; admit = uu___118_4138.admit; lax = uu___118_4138.lax; lax_universes = uu___118_4138.lax_universes; type_of = uu___118_4138.type_of; universe_of = uu___118_4138.universe_of; use_bv_sorts = uu___118_4138.use_bv_sorts; qname_and_index = uu___118_4138.qname_and_index});
))


let push_univ_vars : env  ->  FStar_Syntax_Syntax.univ_names  ->  env = (fun env xs -> (FStar_List.fold_left (fun env x -> (push_local_binding env (Binding_univ (x)))) env xs))


let set_expected_typ : env  ->  FStar_Syntax_Syntax.typ  ->  env = (fun env t -> (

let uu___119_4153 = env
in {solver = uu___119_4153.solver; range = uu___119_4153.range; curmodule = uu___119_4153.curmodule; gamma = uu___119_4153.gamma; gamma_cache = uu___119_4153.gamma_cache; modules = uu___119_4153.modules; expected_typ = Some (t); sigtab = uu___119_4153.sigtab; is_pattern = uu___119_4153.is_pattern; instantiate_imp = uu___119_4153.instantiate_imp; effects = uu___119_4153.effects; generalize = uu___119_4153.generalize; letrecs = uu___119_4153.letrecs; top_level = uu___119_4153.top_level; check_uvars = uu___119_4153.check_uvars; use_eq = false; is_iface = uu___119_4153.is_iface; admit = uu___119_4153.admit; lax = uu___119_4153.lax; lax_universes = uu___119_4153.lax_universes; type_of = uu___119_4153.type_of; universe_of = uu___119_4153.universe_of; use_bv_sorts = uu___119_4153.use_bv_sorts; qname_and_index = uu___119_4153.qname_and_index}))


let expected_typ : env  ->  FStar_Syntax_Syntax.typ Prims.option = (fun env -> (match (env.expected_typ) with
| None -> begin
None
end
| Some (t) -> begin
Some (t)
end))


let clear_expected_typ : env  ->  (env * FStar_Syntax_Syntax.typ Prims.option) = (fun env -> (let _0_242 = (expected_typ env)
in (((

let uu___120_4167 = env
in {solver = uu___120_4167.solver; range = uu___120_4167.range; curmodule = uu___120_4167.curmodule; gamma = uu___120_4167.gamma; gamma_cache = uu___120_4167.gamma_cache; modules = uu___120_4167.modules; expected_typ = None; sigtab = uu___120_4167.sigtab; is_pattern = uu___120_4167.is_pattern; instantiate_imp = uu___120_4167.instantiate_imp; effects = uu___120_4167.effects; generalize = uu___120_4167.generalize; letrecs = uu___120_4167.letrecs; top_level = uu___120_4167.top_level; check_uvars = uu___120_4167.check_uvars; use_eq = false; is_iface = uu___120_4167.is_iface; admit = uu___120_4167.admit; lax = uu___120_4167.lax; lax_universes = uu___120_4167.lax_universes; type_of = uu___120_4167.type_of; universe_of = uu___120_4167.universe_of; use_bv_sorts = uu___120_4167.use_bv_sorts; qname_and_index = uu___120_4167.qname_and_index})), (_0_242))))


let finish_module : env  ->  FStar_Syntax_Syntax.modul  ->  env = (

let empty_lid = (FStar_Ident.lid_of_ids (((FStar_Ident.id_of_text ""))::[]))
in (fun env m -> (

let sigs = (match ((FStar_Ident.lid_equals m.FStar_Syntax_Syntax.name FStar_Syntax_Const.prims_lid)) with
| true -> begin
(let _0_243 = (FStar_All.pipe_right env.gamma (FStar_List.collect (fun uu___102_4182 -> (match (uu___102_4182) with
| Binding_sig (uu____4184, se) -> begin
(se)::[]
end
| uu____4188 -> begin
[]
end))))
in (FStar_All.pipe_right _0_243 FStar_List.rev))
end
| uu____4189 -> begin
m.FStar_Syntax_Syntax.exports
end)
in ((add_sigelts env sigs);
(

let uu___121_4191 = env
in {solver = uu___121_4191.solver; range = uu___121_4191.range; curmodule = empty_lid; gamma = []; gamma_cache = uu___121_4191.gamma_cache; modules = (m)::env.modules; expected_typ = uu___121_4191.expected_typ; sigtab = uu___121_4191.sigtab; is_pattern = uu___121_4191.is_pattern; instantiate_imp = uu___121_4191.instantiate_imp; effects = uu___121_4191.effects; generalize = uu___121_4191.generalize; letrecs = uu___121_4191.letrecs; top_level = uu___121_4191.top_level; check_uvars = uu___121_4191.check_uvars; use_eq = uu___121_4191.use_eq; is_iface = uu___121_4191.is_iface; admit = uu___121_4191.admit; lax = uu___121_4191.lax; lax_universes = uu___121_4191.lax_universes; type_of = uu___121_4191.type_of; universe_of = uu___121_4191.universe_of; use_bv_sorts = uu___121_4191.use_bv_sorts; qname_and_index = uu___121_4191.qname_and_index});
))))


let uvars_in_env : env  ->  FStar_Syntax_Syntax.uvars = (fun env -> (

let no_uvs = (FStar_Syntax_Syntax.new_uv_set ())
in (

let ext = (fun out uvs -> (FStar_Util.set_union out uvs))
in (

let rec aux = (fun out g -> (match (g) with
| [] -> begin
out
end
| (Binding_univ (uu____4241))::tl -> begin
(aux out tl)
end
| ((Binding_lid (_, (_, t)))::tl) | ((Binding_var ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}))::tl) -> begin
(let _0_245 = (let _0_244 = (FStar_Syntax_Free.uvars t)
in (ext out _0_244))
in (aux _0_245 tl))
end
| ((Binding_sig (_))::_) | ((Binding_sig_inst (_))::_) -> begin
out
end))
in (aux no_uvs env.gamma)))))


let univ_vars : env  ->  FStar_Syntax_Syntax.universe_uvar FStar_Util.set = (fun env -> (

let no_univs = FStar_Syntax_Syntax.no_universe_uvars
in (

let ext = (fun out uvs -> (FStar_Util.set_union out uvs))
in (

let rec aux = (fun out g -> (match (g) with
| [] -> begin
out
end
| ((Binding_sig_inst (_))::tl) | ((Binding_univ (_))::tl) -> begin
(aux out tl)
end
| ((Binding_lid (_, (_, t)))::tl) | ((Binding_var ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}))::tl) -> begin
(let _0_247 = (let _0_246 = (FStar_Syntax_Free.univs t)
in (ext out _0_246))
in (aux _0_247 tl))
end
| (Binding_sig (uu____4308))::uu____4309 -> begin
out
end))
in (aux no_univs env.gamma)))))


let univnames : env  ->  FStar_Syntax_Syntax.univ_name FStar_Util.set = (fun env -> (

let no_univ_names = FStar_Syntax_Syntax.no_universe_names
in (

let ext = (fun out uvs -> (FStar_Util.set_union out uvs))
in (

let rec aux = (fun out g -> (match (g) with
| [] -> begin
out
end
| (Binding_sig_inst (uu____4346))::tl -> begin
(aux out tl)
end
| (Binding_univ (uname))::tl -> begin
(let _0_248 = (FStar_Util.set_add uname out)
in (aux _0_248 tl))
end
| ((Binding_lid (_, (_, t)))::tl) | ((Binding_var ({FStar_Syntax_Syntax.ppname = _; FStar_Syntax_Syntax.index = _; FStar_Syntax_Syntax.sort = t}))::tl) -> begin
(let _0_250 = (let _0_249 = (FStar_Syntax_Free.univnames t)
in (ext out _0_249))
in (aux _0_250 tl))
end
| (Binding_sig (uu____4368))::uu____4369 -> begin
out
end))
in (aux no_univ_names env.gamma)))))


let bound_vars_of_bindings : binding Prims.list  ->  FStar_Syntax_Syntax.bv Prims.list = (fun bs -> (FStar_All.pipe_right bs (FStar_List.collect (fun uu___103_4385 -> (match (uu___103_4385) with
| Binding_var (x) -> begin
(x)::[]
end
| (Binding_lid (_)) | (Binding_sig (_)) | (Binding_univ (_)) | (Binding_sig_inst (_)) -> begin
[]
end)))))


let binders_of_bindings : binding Prims.list  ->  FStar_Syntax_Syntax.binders = (fun bs -> (let _0_252 = (let _0_251 = (bound_vars_of_bindings bs)
in (FStar_All.pipe_right _0_251 (FStar_List.map FStar_Syntax_Syntax.mk_binder)))
in (FStar_All.pipe_right _0_252 FStar_List.rev)))


let bound_vars : env  ->  FStar_Syntax_Syntax.bv Prims.list = (fun env -> (bound_vars_of_bindings env.gamma))


let all_binders : env  ->  FStar_Syntax_Syntax.binders = (fun env -> (binders_of_bindings env.gamma))


let fold_env = (fun env f a -> (FStar_List.fold_right (fun e a -> (f a e)) env.gamma a))


let lidents : env  ->  FStar_Ident.lident Prims.list = (fun env -> (

let keys = (FStar_List.fold_left (fun keys uu___104_4446 -> (match (uu___104_4446) with
| Binding_sig (lids, uu____4450) -> begin
(FStar_List.append lids keys)
end
| uu____4453 -> begin
keys
end)) [] env.gamma)
in (FStar_Util.smap_fold (sigtab env) (fun uu____4455 v keys -> (FStar_List.append (FStar_Syntax_Util.lids_of_sigelt v) keys)) keys)))


let dummy_solver : solver_t = {init = (fun uu____4459 -> ()); push = (fun uu____4460 -> ()); pop = (fun uu____4461 -> ()); mark = (fun uu____4462 -> ()); reset_mark = (fun uu____4463 -> ()); commit_mark = (fun uu____4464 -> ()); encode_modul = (fun uu____4465 uu____4466 -> ()); encode_sig = (fun uu____4467 uu____4468 -> ()); solve = (fun uu____4469 uu____4470 uu____4471 -> ()); is_trivial = (fun uu____4475 uu____4476 -> false); finish = (fun uu____4477 -> ()); refresh = (fun uu____4478 -> ())}




