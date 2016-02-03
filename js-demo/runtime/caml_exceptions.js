// Js_of_ocaml runtime support
// http://www.ocsigen.org/js_of_ocaml/
// Copyright (C) 2014 Jérôme Vouillon, Hugo Heuzard, Andy Ray
// Laboratoire PPS - CNRS Université Paris Diderot
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, with linking exception;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//  Copyright (c) 2015 Bloomberg LP. All rights reserved. 
// Hongbo Zhang (hzhang295@bloomberg.net)              
"use strict";
define(["require", "exports"], function (require, exports) {
    /**
     * Exported for better inlining
     * It's common that we have <code> a = caml_set_oo_id([248,"string",0])</code>
     * This can be inlined as <code> a = caml_set_oo_id([248,"tag", caml_oo_last_id++])</code>
     * @type {number}
     */
    var caml_oo_last_id = 0;
    exports.caml_oo_last_id = caml_oo_last_id;
    function caml_set_oo_id(b) {
        b[2] = caml_oo_last_id++;
        return b;
    }
    exports.caml_set_oo_id = caml_set_oo_id;
    var Out_of_memory = [248, "Out_of_memory", 0];
    exports.Out_of_memory = Out_of_memory;
    var Sys_error = [248, "Sys_error", -1];
    exports.Sys_error = Sys_error;
    var Failure = [248, "Failure", -2];
    exports.Failure = Failure;
    var Invalid_argument = [248, "Invalid_argument", -3];
    exports.Invalid_argument = Invalid_argument;
    var End_of_file = [248, "End_of_file", -4];
    exports.End_of_file = End_of_file;
    var Division_by_zero = [248, "Division_by_zero", -5];
    exports.Division_by_zero = Division_by_zero;
    var Not_found = [248, "Not_found", -6];
    exports.Not_found = Not_found;
    var Match_failure = [248, "Match_failure", -7];
    exports.Match_failure = Match_failure;
    var Stack_overflow = [248, "Stack_overflow", -8];
    exports.Stack_overflow = Stack_overflow;
    var Sys_blocked_io = [248, "Sys_blocked_io", -9];
    exports.Sys_blocked_io = Sys_blocked_io;
    var Assert_failure = [248, "Assert_failure", -10];
    exports.Assert_failure = Assert_failure;
    var Undefined_recursive_module = [248, "Undefined_recursive_module", -11];
    exports.Undefined_recursive_module = Undefined_recursive_module;
    function caml_raise_constant(tag) { throw tag; }
    function caml_return_exn_constant(tag) { return tag; }
    function caml_raise_with_arg(tag, arg) { throw [0, tag, arg]; }
    exports.caml_raise_with_arg = caml_raise_with_arg;
    function caml_raise_with_string(tag, msg) {
        caml_raise_with_arg(tag, msg);
    }
    function caml_raise_sys_error(msg) {
        caml_raise_with_string(Sys_error, msg);
    }
    exports.caml_raise_sys_error = caml_raise_sys_error;
    function caml_invalid_argument(msg) {
        caml_raise_with_string(Invalid_argument, msg);
    }
    exports.caml_invalid_argument = caml_invalid_argument;
    function caml_raise_end_of_file() {
        caml_raise_constant(End_of_file);
    }
    function caml_raise_zero_divide() {
        caml_raise_constant(Division_by_zero);
    }
    exports.caml_raise_zero_divide = caml_raise_zero_divide;
    function caml_raise_not_found() {
        caml_raise_constant(Not_found);
    }
    exports.caml_raise_not_found = caml_raise_not_found;
    function caml_array_bound_error() {
        caml_invalid_argument("index out of bounds");
    }
    exports.caml_array_bound_error = caml_array_bound_error;
    /**
     * This function does not exist in runtime
     * However, we still need here since we need write some low-level code which
     * needs such utilities, if we write such low level code in OCaml itself, maybe
     * we can remove it
     * void caml_failwith(char const *msg)
     * asmrun/fail.c
     * @param msg
     */
    function caml_failwith(msg) {
        caml_raise_with_string(Failure, msg);
    }
    exports.caml_failwith = caml_failwith;
    //Provides: caml_wrap_exception const (const)
    //Requires: caml_global_data,caml_js_to_string,caml_named_value
    //Requires: caml_return_exn_constant
    //function caml_wrap_exception(e) {
    //  if(e instanceof Array) return e;
    //  //Stack_overflow: chrome, safari
    //  if(RangeError !== undefined
    //     && e instanceof RangeError
    //     && e.message
    //     && e.message.match(/maximum call stack/i))
    //    return caml_return_exn_constant(caml_global_data["Stack_overflow"]);
    //  //Stack_overflow: firefox
    //  if(InternalError !== undefined
    //     && e instanceof InternalError
    //     && e.message
    //     && e.message.match(/too much recursion/i))
    //    return caml_return_exn_constant(caml_global_data["Stack_overflow"]);
    //  //Wrap Error in Js.Error exception
    //  if(e instanceof Error)
    //    return [0,caml_named_value("jsError"),e];
    //  //fallback: wrapped in Failure
    //  return [0,caml_global_data["Failure"],String(e)];
    //}
});
