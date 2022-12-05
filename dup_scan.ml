open Lwt
open Cohttp
open Cohttp_lwt_unix

module ConNum = Map.Make(String)

let map_ConNum = ref ConNum.empty

let rec get_issues page_num res =
    let body =
        Client.get ~headers: (Cohttp.Header.init_with "accept" "application/vnd.github+json") (Uri.of_string ("https://api.github.com/repos/" ^ Sys.argv.(3) ^ "/issues?state=all&per_page=100&" ^ "page=" ^ (Int.to_string page_num))) >>= fun (_, body) ->
            Cohttp_lwt.Body.to_string body in
    
    let issue_tup =
        let body = Lwt_main.run body in
            let open Yojson.Basic.Util in
                ([body |> Yojson.Basic.from_string]
                    |> flatten
                    |> filter_member "body"
                    |> filter_string,
                [body |> Yojson.Basic.from_string]
                    |> flatten
                    |> filter_member "number"
                    |> filter_int) 
    in

    let issue_list = fst issue_tup in
    let num_list = snd issue_tup in

    if List.length issue_list == 0 then []
    else
        let _ = List.iter2 (fun content num ->
            Printf.printf "contents: %s, num: %d\n" content num;
            if num != int_of_string (Sys.argv.(1)) then
                let _ = map_ConNum := ConNum.add content num !map_ConNum in
                Printf.printf "put %d\n" num;
        ) issue_list num_list in
                
        issue_list @ (get_issues (page_num+1) res)

let sim_header = Cohttp.Header.of_list [("X-RapidAPI-Key", Sys.argv.(4)); ("X-RapidAPI-Host", "twinword-text-similarity-v1.p.rapidapi.com"); ("content-type", "application/x-www-form-urlencoded")]

let threshold_sim = if Option.is_some (float_of_string_opt (Sys.argv.(6))) then float_of_string (Sys.argv.(6))
    else 0.20
let max_sim = ref (-1.0)
let max_contents = ref ""

let () = List.iter (fun issue_contents -> 
    let text1 = Yojson.Basic.to_string (`String (String.sub (Sys.argv.(2)) 9 ((String.length (Sys.argv.(2))) - 9))) in
    let text2 = Yojson.Basic.to_string (`String issue_contents) in
    Printf.printf "Text1:%s\nText2:%s\n\n" text1 text2;

    if ConNum.mem issue_contents (!map_ConNum) then
        let _ = Printf.printf "Comparison %s and %s\n" text1 text2 in
        let body =
            Client.get  ~headers:sim_header (Uri.of_string ("https://twinword-text-similarity-v1.p.rapidapi.com/similarity/?" ^ "text1=" ^ text1 ^ "&" ^ "text2=" ^ text2)) >>= fun (_, body) ->
                Cohttp_lwt.Body.to_string body in
        
        let body = Lwt_main.run body in
            let json_body = Yojson.Basic.from_string body in
                let open Yojson.Basic.Util in
                    let cur_sim = List.hd ([json_body] |> filter_member "similarity" |> filter_number) in
                        if cur_sim > threshold_sim && cur_sim > (!max_sim) then
                            let _ = max_sim := cur_sim in
                            let _ = max_contents := issue_contents in
                            Printf.printf "max updated! sim: %f, contents: %s\n" !max_sim !max_contents;
) (get_issues 1 [])

let _ = Printf.printf "%s has %f\n" !max_contents !max_sim


let _ = 
    if !max_sim != (-1.0) then
        let _ = Sys.command ("echo \"dup_num=" ^ (Int.to_string (ConNum.find !max_contents !map_ConNum)) ^ "\" >> $GITHUB_OUTPUT") in
        let detected_num = (ConNum.find !max_contents !map_ConNum) in

        let body =
            (* Leave a comment *)
            let comment_body = Cohttp_lwt.Body.of_string (Yojson.Basic.to_string (
                `Assoc[("body", (`String ("Possible duplication detected. Refer to #" ^ (Int.to_string detected_num))))]
            )) in
            let comment_header = Cohttp.Header.add_authorization (Cohttp.Header.init_with "accept" "application/vnd.github+json") (Cohttp.Auth.credential_of_string ("Bearer " ^ Sys.argv.(5))) in
        
            Client.post 
                ~body:comment_body 
                ~headers:comment_header 
                (Uri.of_string ("https://api.github.com/repos/" ^ Sys.argv.(3) ^ "/issues/" ^ Sys.argv.(1) ^ "/comments")) 
                >>= fun (resp, body) ->
                    let code = resp |> Response.status |> Code.code_of_status in
                        Printf.printf "Response code: %d\n" code;
                    Cohttp_lwt.Body.to_string body in
        
            let body = Lwt_main.run body in
                print_endline body
    else 
        let _ = Sys.command ("echo \"dup_num=-1\" >> $GITHUB_OUTPUT") in ()