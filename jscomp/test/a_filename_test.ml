let suites :  Mt.pair_suites ref  = ref []
let test_id = ref 0
let eq loc x y = 
  incr test_id ; 
  suites := 
    (loc ^" id " ^ (string_of_int !test_id), (fun _ -> Mt.Eq(x,y))) :: !suites


let () =
  eq __LOC__ 
    (let (//) = Ext_filename.combine in 
     ("/tmp"// "subdir/file.txt",
      "/tmp"// "/a/tmp.txt",
      "/a/tmp.txt" // "subdir/file.txt"      
    ))
    ("/tmp/subdir/file.txt",
     "/a/tmp.txt",
     "/a/tmp.txt/subdir/file.txt"      
    )

  ;    
  eq __LOC__
    (Ext_filename.node_relative_path 
       (`File "./a/b.c")
       (`File "./a/u/g.c")) "./u/g";

  eq __LOC__ 
    (Ext_filename.node_relative_path
       (`File "./a/b.c")
       (`File "xxxghsoghos/ghsoghso/node_modules/buckle-stdlib/list.js"))
    "buckle-stdlib/list.js" ;

  eq __LOC__ 
    (Ext_filename.node_relative_path
           (`File "./a/b.c")
           (`File "xxxghsoghos/ghsoghso/node_modules//buckle-stdlib/list.js"))
         "buckle-stdlib/list.js" ;

  eq __LOC__ 
    (Ext_filename.node_relative_path
           (`File "./a/b.c")
           (`File "xxxghsoghos/ghsoghso/node_modules/./buckle-stdlib/list.js"))
    "buckle-stdlib/list.js"    ;

  eq __LOC__ 
    (Ext_filename.node_relative_path
           (`File "./a/c.js")
           (`File "./a/b"))
    "./b"         ;
  eq __LOC__ 
    (Ext_filename.node_relative_path
           (`File "./a/c")
           (`File "./a/b.js"))
    "./b"         ;
  eq __LOC__
    (Ext_filename.node_relative_path
           (`Dir "./a/")
           (`File "./a/b.js"))
    "./b"



;; Mt.from_pair_suites __FILE__ !suites
