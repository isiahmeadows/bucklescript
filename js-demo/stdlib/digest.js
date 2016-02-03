// Generated CODE, PLEASE EDIT WITH CARE
'use strict';
define(["./bytes","./pervasives","../runtime/caml_exceptions","./char","../runtime/caml_primitive","./string"],
  function(Bytes,Pervasives,Caml_exceptions,Char,Caml_primitive,$$String){
    'use strict';
    function string(str) {
      return Caml_primitive.caml_md5_string(str, 0, str.length);
    }
    
    function bytes(b) {
      return string(Bytes.unsafe_to_string(b));
    }
    
    function substring(str, ofs, len) {
      if (ofs < 0 || len < 0 || ofs > str.length - len) {
        return Pervasives.invalid_arg("Digest.substring");
      }
      else {
        return Caml_primitive.caml_md5_string(str, ofs, len);
      }
    }
    
    function subbytes(b, ofs, len) {
      return substring(Bytes.unsafe_to_string(b), ofs, len);
    }
    
    function file(filename) {
      var ic = Pervasives.open_in_bin(filename);
      var exit = 0;
      var d;
      try {
        d = Caml_primitive.caml_md5_chan(ic, -1);
        exit = 1;
      }
      catch (e){
        Pervasives.close_in(ic);
        throw e;
      }
      if (exit === 1) {
        Pervasives.close_in(ic);
        return d;
      }
      
    }
    
    function output(chan, digest) {
      return Pervasives.output_string(chan, digest);
    }
    
    function input(chan) {
      return Pervasives.really_input_string(chan, 16);
    }
    
    function char_hex(n) {
      return n + (
              n < 10 ? /* "0" */48 : 87
            );
    }
    
    function to_hex(d) {
      var result = new Array(32);
      for(var i = 0; i<= 15; ++i){
        var x = d.charCodeAt(i);
        result[i * 2] = char_hex((x >>> 4));
        result[i * 2 + 1] = char_hex(x & 15);
      }
      return Bytes.unsafe_to_string(result);
    }
    
    function from_hex(s) {
      if (s.length !== 32) {
        throw [
              0,
              Caml_exceptions.Invalid_argument,
              "Digest.from_hex"
            ];
      }
      var digit = function (c) {
        if (c >= 65) {
          if (c >= 97) {
            if (c >= 103) {
              throw [
                    0,
                    Caml_exceptions.Invalid_argument,
                    "Digest.from_hex"
                  ];
            }
            else {
              return c - /* "a" */97 + 10;
            }
          }
          else if (c >= 71) {
            throw [
                  0,
                  Caml_exceptions.Invalid_argument,
                  "Digest.from_hex"
                ];
          }
          else {
            return c - /* "A" */65 + 10;
          }
        }
        else if (c > 57 || c < 48) {
          throw [
                0,
                Caml_exceptions.Invalid_argument,
                "Digest.from_hex"
              ];
        }
        else {
          return c - /* "0" */48;
        }
      };
      var $$byte = function (i) {
        return (digit(s.charCodeAt(i)) << 4) + digit(s.charCodeAt(i + 1));
      };
      var result = new Array(16);
      for(var i = 0; i<= 15; ++i){
        result[i] = Char.chr($$byte(2 * i));
      }
      return Bytes.unsafe_to_string(result);
    }
    
    var compare = $$String.compare;
    return {
      compare : compare, 
      string : string, 
      bytes : bytes, 
      substring : substring, 
      subbytes : subbytes, 
      file : file, 
      output : output, 
      input : input, 
      to_hex : to_hex, 
      from_hex : from_hex
    }
  })
/* No side effect */
