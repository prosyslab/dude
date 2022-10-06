let issue_num = Sys.argv.(1) in
    let issue_contents = Sys.argv.(2) in
        let _ = (Printf.printf "%s and %s\n" issue_num issue_contents) in
            Printf.printf "::set-output name=string::%s\n" issue_contents