(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)








(** Used when produce node compatible paths *)
let node_sep = "/"
let node_parent = ".."
let node_current = "."

type t = 
  [ `File of string 
  | `Dir of string ]

let cwd = lazy (Sys.getcwd ())

let (//) = Filename.concat 

let combine path1 path2 =
  if path1 = "" then
    path2
  else if path2 = "" then path1
  else 
  if Filename.is_relative path2 then
     path1// path2 
  else
    path2

(* Note that [.//] is the same as [./] *)
let path_as_directory x =
  if x = "" then x
  else
  if Ext_string.ends_with x  Filename.dir_sep then
    x 
  else 
    x ^ Filename.dir_sep

let absolute_path s = 
  let process s = 
    let s = 
      if Filename.is_relative s then
        Lazy.force cwd // s 
      else s in
    (* Now simplify . and .. components *)
    let rec aux s =
      let base,dir  = Filename.basename s, Filename.dirname s  in
      if dir = s then dir
      else if base = Filename.current_dir_name then aux dir
      else if base = Filename.parent_dir_name then Filename.dirname (aux dir)
      else aux dir // base
    in aux s  in 
  match s with 
  | `File x -> `File (process x )
  | `Dir x -> `Dir (process x)


let chop_extension ?(loc="") name =
  try Filename.chop_extension name 
  with Invalid_argument _ -> 
    Ext_pervasives.invalid_argf 
      "Filename.chop_extension ( %s : %s )"  loc name

let try_chop_extension s = try Filename.chop_extension s with _ -> s 

(** example
    {[
    "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/external/pervasives.cmj"
    "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/ocaml_array.ml"
    ]}

    The other way
    {[
    
    "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/ocaml_array.ml"
    "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib/external/pervasives.cmj"
    ]}
    {[
    "/bb/mbigc/mbig2899/bgit/bucklescript/jscomp/stdlib//ocaml_array.ml"
    ]}
    {[
    /a/b
    /c/d
    ]}
 *)
let relative_path file_or_dir_1 file_or_dir_2 = 
  let sep_char = Filename.dir_sep.[0] in
  let relevant_dir1 = 
    (match file_or_dir_1 with 
    | `Dir x -> x 
    | `File file1 ->  Filename.dirname file1) in
  let relevant_dir2 = 
    (match file_or_dir_2 with 
    |`Dir x -> x 
    |`File file2 -> Filename.dirname file2 ) in
  let dir1 = Ext_string.split relevant_dir1 sep_char   in
  let dir2 = Ext_string.split relevant_dir2 sep_char  in
  let rec go (dir1 : string list) (dir2 : string list) = 
    match dir1, dir2 with 
    | x::xs , y :: ys when x = y
      -> go xs ys 
    | _, _
      -> 
        List.map (fun _ -> node_parent) dir2 @ dir1 
  in
  match go dir1 dir2 with
  | (x :: _ ) as ys when x = node_parent -> 
      String.concat node_sep ys
  | ys -> 
      String.concat node_sep  @@ node_current :: ys



let node_modules = "node_modules"
let node_modules_length = String.length "node_modules"
let package_json = "package.json"




(** path2: a/b 
    path1: a 
    result:  ./b 
    TODO: [Filename.concat] with care

    [file1] is currently compilation file 
    [file2] is the dependency
 *)
let node_relative_path (file1 : t) 
    (`File file2 as dep_file : [`File of string]) = 
  let v = Ext_string.find  file2 ~sub:node_modules in 
  let len = String.length file2 in 
  if v >= 0 then 
    let rec skip  i =       
      if i >= len then
        Ext_pervasives.failwithf ~loc:__LOC__ "invalid path: %s"  file2
      else 
        match file2.[i] with 
        | '/'
        | '.' ->  skip (i + 1) 
        | _ -> i
        (*
          TODO: we need do more than this suppose user 
          input can be
           {[
           "xxxghsoghos/ghsoghso/node_modules/../buckle-stdlib/list.js"
           ]}
           This seems weird though
        *)
    in 
    Ext_string.tail_from file2
      (skip (v + node_modules_length)) 
  else 
    relative_path 
       (absolute_path dep_file)
       (absolute_path file1)
     ^ node_sep ^
    try_chop_extension (Filename.basename file2)



(** [resolve cwd module_name], 
    [cwd] is current working directory, absolute path
    Trying to find paths to load [module_name]
    it is sepcialized for option [-bs-package-include] which requires
    [npm_package_name/lib/ocaml]
*)
let  resolve_bs_package ~cwd name = 
  let sub_path = name // "lib" // "ocaml" in
  let rec aux origin cwd name = 
    let destdir =  cwd // node_modules // sub_path in 
    if Ext_sys.is_directory_no_exn destdir then destdir
    else 
      let cwd' = Filename.dirname cwd in 
      if String.length cwd' < String.length cwd then  
        aux origin   cwd' name
      else 
        try 
          let destdir = 
            Sys.getenv "npm_config_prefix" 
            // "lib" // node_modules // sub_path in
          if Ext_sys.is_directory_no_exn destdir
          then destdir
          else
            Ext_pervasives.failwithf
              ~loc:__LOC__ " %s not found in %s" name origin 

        with 
          Not_found -> 
          Ext_pervasives.failwithf
            ~loc:__LOC__ " %s not found in %s" name origin 
  in
  aux cwd cwd name


let find_package_json_dir cwd  = 
  let rec aux cwd  = 
    if Sys.file_exists (cwd // package_json) then cwd
    else 
      let cwd' = Filename.dirname cwd in 
      if String.length cwd' < String.length cwd then  
        aux cwd'
      else 
        Ext_pervasives.failwithf 
          ~loc:__LOC__
            "package.json not found from %s" cwd
  in
  aux cwd 

let package_dir = lazy (find_package_json_dir (Lazy.force cwd))

let replace_backward_slash (x : string)= 
  String.map (function 
    |'\\'-> '/'
    | x -> x) x  
