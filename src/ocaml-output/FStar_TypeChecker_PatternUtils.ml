open Prims
type lcomp_with_binder =
  (FStar_Syntax_Syntax.bv FStar_Pervasives_Native.option *
    FStar_Syntax_Syntax.lcomp)
let rec (elaborate_pat :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.pat -> FStar_Syntax_Syntax.pat)
  =
  fun env  ->
    fun p  ->
      let maybe_dot inaccessible a r =
        if inaccessible
        then
          FStar_Syntax_Syntax.withinfo
            (FStar_Syntax_Syntax.Pat_dot_term (a, FStar_Syntax_Syntax.tun)) r
        else FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_var a) r
         in
      match p.FStar_Syntax_Syntax.v with
      | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
          let pats1 =
            FStar_List.map
              (fun uu____55864  ->
                 match uu____55864 with
                 | (p1,imp) ->
                     let uu____55879 = elaborate_pat env p1  in
                     (uu____55879, imp)) pats
             in
          let uu____55881 =
            FStar_TypeChecker_Env.lookup_datacon env
              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
             in
          (match uu____55881 with
           | (uu____55886,t) ->
               let uu____55888 = FStar_Syntax_Util.arrow_formals t  in
               (match uu____55888 with
                | (f,uu____55904) ->
                    let rec aux formals pats2 =
                      match (formals, pats2) with
                      | ([],[]) -> []
                      | ([],uu____56042::uu____56043) ->
                          let uu____56090 =
                            FStar_Ident.range_of_lid
                              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                             in
                          FStar_Errors.raise_error
                            (FStar_Errors.Fatal_TooManyPatternArguments,
                              "Too many pattern arguments") uu____56090
                      | (uu____56102::uu____56103,[]) ->
                          FStar_All.pipe_right formals
                            (FStar_List.map
                               (fun uu____56185  ->
                                  match uu____56185 with
                                  | (t1,imp) ->
                                      (match imp with
                                       | FStar_Pervasives_Native.Some
                                           (FStar_Syntax_Syntax.Implicit
                                           inaccessible) ->
                                           let a =
                                             let uu____56215 =
                                               let uu____56218 =
                                                 FStar_Syntax_Syntax.range_of_bv
                                                   t1
                                                  in
                                               FStar_Pervasives_Native.Some
                                                 uu____56218
                                                in
                                             FStar_Syntax_Syntax.new_bv
                                               uu____56215
                                               FStar_Syntax_Syntax.tun
                                              in
                                           let r =
                                             FStar_Ident.range_of_lid
                                               (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                              in
                                           let uu____56220 =
                                             maybe_dot inaccessible a r  in
                                           (uu____56220, true)
                                       | uu____56227 ->
                                           let uu____56230 =
                                             let uu____56236 =
                                               let uu____56238 =
                                                 FStar_Syntax_Print.pat_to_string
                                                   p
                                                  in
                                               FStar_Util.format1
                                                 "Insufficient pattern arguments (%s)"
                                                 uu____56238
                                                in
                                             (FStar_Errors.Fatal_InsufficientPatternArguments,
                                               uu____56236)
                                              in
                                           let uu____56242 =
                                             FStar_Ident.range_of_lid
                                               (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                              in
                                           FStar_Errors.raise_error
                                             uu____56230 uu____56242)))
                      | (f1::formals',(p1,p_imp)::pats') ->
                          (match f1 with
                           | (uu____56323,FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit inaccessible))
                               when inaccessible && p_imp ->
                               (match p1.FStar_Syntax_Syntax.v with
                                | FStar_Syntax_Syntax.Pat_dot_term
                                    uu____56337 ->
                                    let uu____56344 = aux formals' pats'  in
                                    (p1, true) :: uu____56344
                                | FStar_Syntax_Syntax.Pat_wild uu____56365 ->
                                    let a =
                                      FStar_Syntax_Syntax.new_bv
                                        (FStar_Pervasives_Native.Some
                                           (p1.FStar_Syntax_Syntax.p))
                                        FStar_Syntax_Syntax.tun
                                       in
                                    let p2 =
                                      let uu____56370 =
                                        FStar_Ident.range_of_lid
                                          (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                         in
                                      maybe_dot inaccessible a uu____56370
                                       in
                                    let uu____56371 = aux formals' pats'  in
                                    (p2, true) :: uu____56371
                                | uu____56392 ->
                                    let uu____56393 =
                                      let uu____56399 =
                                        let uu____56401 =
                                          FStar_Syntax_Print.pat_to_string p1
                                           in
                                        FStar_Util.format1
                                          "This pattern (%s) binds an inaccesible argument; use a wildcard ('_') pattern"
                                          uu____56401
                                         in
                                      (FStar_Errors.Fatal_InsufficientPatternArguments,
                                        uu____56399)
                                       in
                                    FStar_Errors.raise_error uu____56393
                                      p1.FStar_Syntax_Syntax.p)
                           | (uu____56414,FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit uu____56415))
                               when p_imp ->
                               let uu____56419 = aux formals' pats'  in
                               (p1, true) :: uu____56419
                           | (uu____56440,FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit inaccessible)) ->
                               let a =
                                 FStar_Syntax_Syntax.new_bv
                                   (FStar_Pervasives_Native.Some
                                      (p1.FStar_Syntax_Syntax.p))
                                   FStar_Syntax_Syntax.tun
                                  in
                               let p2 =
                                 let uu____56449 =
                                   FStar_Ident.range_of_lid
                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v
                                    in
                                 maybe_dot inaccessible a uu____56449  in
                               let uu____56450 = aux formals' pats2  in
                               (p2, true) :: uu____56450
                           | (uu____56471,imp) ->
                               let uu____56477 =
                                 let uu____56485 =
                                   FStar_Syntax_Syntax.is_implicit imp  in
                                 (p1, uu____56485)  in
                               let uu____56490 = aux formals' pats'  in
                               uu____56477 :: uu____56490)
                       in
                    let uu___598_56507 = p  in
                    let uu____56508 =
                      let uu____56509 =
                        let uu____56523 = aux f pats1  in (fv, uu____56523)
                         in
                      FStar_Syntax_Syntax.Pat_cons uu____56509  in
                    {
                      FStar_Syntax_Syntax.v = uu____56508;
                      FStar_Syntax_Syntax.p =
                        (uu___598_56507.FStar_Syntax_Syntax.p)
                    }))
      | uu____56542 -> p
  
let (pat_as_exp :
  Prims.bool ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.pat ->
        (FStar_Syntax_Syntax.bv Prims.list * FStar_Syntax_Syntax.term *
          FStar_TypeChecker_Env.guard_t * FStar_Syntax_Syntax.pat))
  =
  fun introduce_bv_uvars  ->
    fun env  ->
      fun p  ->
        let intro_bv env1 x =
          if Prims.op_Negation introduce_bv_uvars
          then
            ((let uu___611_56606 = x  in
              {
                FStar_Syntax_Syntax.ppname =
                  (uu___611_56606.FStar_Syntax_Syntax.ppname);
                FStar_Syntax_Syntax.index =
                  (uu___611_56606.FStar_Syntax_Syntax.index);
                FStar_Syntax_Syntax.sort = FStar_Syntax_Syntax.tun
              }), FStar_TypeChecker_Env.trivial_guard, env1)
          else
            (let uu____56609 = FStar_Syntax_Util.type_u ()  in
             match uu____56609 with
             | (t,uu____56621) ->
                 let uu____56622 =
                   let uu____56635 = FStar_Syntax_Syntax.range_of_bv x  in
                   FStar_TypeChecker_Env.new_implicit_var_aux
                     "pattern bv type" uu____56635 env1 t
                     FStar_Syntax_Syntax.Allow_untyped
                     FStar_Pervasives_Native.None
                    in
                 (match uu____56622 with
                  | (t_x,uu____56648,guard) ->
                      let x1 =
                        let uu___620_56663 = x  in
                        {
                          FStar_Syntax_Syntax.ppname =
                            (uu___620_56663.FStar_Syntax_Syntax.ppname);
                          FStar_Syntax_Syntax.index =
                            (uu___620_56663.FStar_Syntax_Syntax.index);
                          FStar_Syntax_Syntax.sort = t_x
                        }  in
                      let uu____56664 = FStar_TypeChecker_Env.push_bv env1 x1
                         in
                      (x1, guard, uu____56664)))
           in
        let rec pat_as_arg_with_env env1 p1 =
          match p1.FStar_Syntax_Syntax.v with
          | FStar_Syntax_Syntax.Pat_constant c ->
              let e =
                match c with
                | FStar_Const.Const_int
                    (repr,FStar_Pervasives_Native.Some sw) ->
                    FStar_ToSyntax_ToSyntax.desugar_machine_integer
                      env1.FStar_TypeChecker_Env.dsenv repr sw
                      p1.FStar_Syntax_Syntax.p
                | uu____56736 ->
                    FStar_Syntax_Syntax.mk
                      (FStar_Syntax_Syntax.Tm_constant c)
                      FStar_Pervasives_Native.None p1.FStar_Syntax_Syntax.p
                 in
              ([], [], [], env1, e, FStar_TypeChecker_Env.trivial_guard, p1)
          | FStar_Syntax_Syntax.Pat_dot_term (x,uu____56744) ->
              let uu____56749 = FStar_Syntax_Util.type_u ()  in
              (match uu____56749 with
               | (k,uu____56775) ->
                   let uu____56776 =
                     let uu____56789 = FStar_Syntax_Syntax.range_of_bv x  in
                     FStar_TypeChecker_Env.new_implicit_var_aux
                       "pat_dot_term type" uu____56789 env1 k
                       FStar_Syntax_Syntax.Allow_untyped
                       FStar_Pervasives_Native.None
                      in
                   (match uu____56776 with
                    | (t,uu____56816,g) ->
                        let x1 =
                          let uu___646_56831 = x  in
                          {
                            FStar_Syntax_Syntax.ppname =
                              (uu___646_56831.FStar_Syntax_Syntax.ppname);
                            FStar_Syntax_Syntax.index =
                              (uu___646_56831.FStar_Syntax_Syntax.index);
                            FStar_Syntax_Syntax.sort = t
                          }  in
                        let uu____56832 =
                          let uu____56845 =
                            FStar_Syntax_Syntax.range_of_bv x1  in
                          FStar_TypeChecker_Env.new_implicit_var_aux
                            "pat_dot_term" uu____56845 env1 t
                            FStar_Syntax_Syntax.Allow_untyped
                            FStar_Pervasives_Native.None
                           in
                        (match uu____56832 with
                         | (e,uu____56872,g') ->
                             let p2 =
                               let uu___653_56889 = p1  in
                               {
                                 FStar_Syntax_Syntax.v =
                                   (FStar_Syntax_Syntax.Pat_dot_term (x1, e));
                                 FStar_Syntax_Syntax.p =
                                   (uu___653_56889.FStar_Syntax_Syntax.p)
                               }  in
                             let uu____56892 =
                               FStar_TypeChecker_Env.conj_guard g g'  in
                             ([], [], [], env1, e, uu____56892, p2))))
          | FStar_Syntax_Syntax.Pat_wild x ->
              let uu____56900 = intro_bv env1 x  in
              (match uu____56900 with
               | (x1,g,env2) ->
                   let e =
                     FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_name x1)
                       FStar_Pervasives_Native.None p1.FStar_Syntax_Syntax.p
                      in
                   ([x1], [], [x1], env2, e, g, p1))
          | FStar_Syntax_Syntax.Pat_var x ->
              let uu____56940 = intro_bv env1 x  in
              (match uu____56940 with
               | (x1,g,env2) ->
                   let e =
                     FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_name x1)
                       FStar_Pervasives_Native.None p1.FStar_Syntax_Syntax.p
                      in
                   ([x1], [x1], [], env2, e, g, p1))
          | FStar_Syntax_Syntax.Pat_cons (fv,pats) ->
              let uu____56999 =
                FStar_All.pipe_right pats
                  (FStar_List.fold_left
                     (fun uu____57138  ->
                        fun uu____57139  ->
                          match (uu____57138, uu____57139) with
                          | ((b,a,w,env2,args,guard,pats1),(p2,imp)) ->
                              let uu____57348 = pat_as_arg_with_env env2 p2
                                 in
                              (match uu____57348 with
                               | (b',a',w',env3,te,guard',pat) ->
                                   let arg =
                                     if imp
                                     then FStar_Syntax_Syntax.iarg te
                                     else FStar_Syntax_Syntax.as_arg te  in
                                   let uu____57427 =
                                     FStar_TypeChecker_Env.conj_guard guard
                                       guard'
                                      in
                                   ((b' :: b), (a' :: a), (w' :: w), env3,
                                     (arg :: args), uu____57427, ((pat, imp)
                                     :: pats1))))
                     ([], [], [], env1, [],
                       FStar_TypeChecker_Env.trivial_guard, []))
                 in
              (match uu____56999 with
               | (b,a,w,env2,args,guard,pats1) ->
                   let e =
                     let uu____57565 =
                       let uu____57570 = FStar_Syntax_Syntax.fv_to_tm fv  in
                       let uu____57571 =
                         FStar_All.pipe_right args FStar_List.rev  in
                       FStar_Syntax_Syntax.mk_Tm_app uu____57570 uu____57571
                        in
                     uu____57565 FStar_Pervasives_Native.None
                       p1.FStar_Syntax_Syntax.p
                      in
                   let uu____57574 =
                     FStar_All.pipe_right (FStar_List.rev b)
                       FStar_List.flatten
                      in
                   let uu____57585 =
                     FStar_All.pipe_right (FStar_List.rev a)
                       FStar_List.flatten
                      in
                   let uu____57596 =
                     FStar_All.pipe_right (FStar_List.rev w)
                       FStar_List.flatten
                      in
                   (uu____57574, uu____57585, uu____57596, env2, e, guard,
                     (let uu___704_57614 = p1  in
                      {
                        FStar_Syntax_Syntax.v =
                          (FStar_Syntax_Syntax.Pat_cons
                             (fv, (FStar_List.rev pats1)));
                        FStar_Syntax_Syntax.p =
                          (uu___704_57614.FStar_Syntax_Syntax.p)
                      })))
           in
        let one_pat env1 p1 =
          let p2 = elaborate_pat env1 p1  in
          let uu____57659 = pat_as_arg_with_env env1 p2  in
          match uu____57659 with
          | (b,a,w,env2,arg,guard,p3) ->
              let uu____57717 =
                FStar_All.pipe_right b
                  (FStar_Util.find_dup FStar_Syntax_Syntax.bv_eq)
                 in
              (match uu____57717 with
               | FStar_Pervasives_Native.Some x ->
                   let m = FStar_Syntax_Print.bv_to_string x  in
                   let err =
                     let uu____57751 =
                       FStar_Util.format1
                         "The pattern variable \"%s\" was used more than once"
                         m
                        in
                     (FStar_Errors.Fatal_NonLinearPatternVars, uu____57751)
                      in
                   FStar_Errors.raise_error err p3.FStar_Syntax_Syntax.p
               | uu____57773 -> (b, a, w, arg, guard, p3))
           in
        let uu____57782 = one_pat env p  in
        match uu____57782 with
        | (b,uu____57812,uu____57813,tm,guard,p1) -> (b, tm, guard, p1)
  