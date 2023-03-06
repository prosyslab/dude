open Lwt
open Cohttp
open Cohttp_lwt_unix

module IntMap = Map.Make (struct
  type t = int

  let compare = compare
end)

let rec get_issues repo page_num map =
  let body =
    Client.get
      ~headers:(Cohttp.Header.init_with "accept" "application/vnd.github+json")
      (Uri.of_string
         ("https://api.github.com/repos/" ^ repo
        ^ "/issues?state=all&per_page=100&" ^ "page=" ^ Int.to_string page_num))
    >>= fun (_, body) -> Cohttp_lwt.Body.to_string body
  in

  let bodies, numbers =
    let open Yojson.Basic.Util in
    let response = Lwt_main.run body in
    let body = [ response |> Yojson.Basic.from_string ] |> flatten in
    (body |> filter_member "body", body |> filter_member "number" |> filter_int)
  in
  let issue_list =
    List.map
      (fun issue_raw ->
        let issue_opt = Yojson.Basic.Util.to_string_option issue_raw in
        if Option.is_some issue_opt then Option.get issue_opt else "")
      bodies
  in
  if issue_list = [] then map
  else
    List.fold_left2
      (fun map body number -> IntMap.add number body map)
      map issue_list numbers
    |> get_issues repo (page_num + 1)

let find_max_sim issue_num issue_contents rapid_key threshold map =
  let headers =
    Cohttp.Header.of_list
      [
        ("X-RapidAPI-Key", rapid_key);
        ("X-RapidAPI-Host", "twinword-text-similarity-v1.p.rapidapi.com");
        ("content-type", "application/x-www-form-urlencoded");
      ]
  in
  IntMap.fold
    (fun num content (max_sim, max_num) ->
      if num = issue_num then (max_sim, max_num)
      else
        let text1 =
          Yojson.Basic.to_string
            (`String
              (String.sub issue_contents 9 (String.length issue_contents - 9)))
        in
        let text2 = Yojson.Basic.to_string (`String content) in
        Printf.eprintf "Text1:%s\nText2:%s\n\n" text1 text2;
        let _ = Printf.eprintf "Comparison %s and %s\n" text1 text2 in
        let body =
          Client.get ~headers
            (Uri.of_string
               ("https://twinword-text-similarity-v1.p.rapidapi.com/similarity/?"
              ^ "text1=" ^ text1 ^ "&" ^ "text2=" ^ text2))
          >>= fun (_, body) -> Cohttp_lwt.Body.to_string body
        in
        let body = Lwt_main.run body in
        let json_body = Yojson.Basic.from_string body in
        let open Yojson.Basic.Util in
        Printf.eprintf "body: %s\n" body;
        let cur_sim =
          List.hd ([ json_body ] |> filter_member "similarity" |> filter_number)
        in
        if cur_sim > threshold && cur_sim > max_sim then (cur_sim, num)
        else (max_sim, max_num))
    map (-1.0, -1)

let write_comment issue_num repo repo_key max_num =
  let body =
    let comment_body =
      Cohttp_lwt.Body.of_string
        (Yojson.Basic.to_string
           (`Assoc
             [
               ( "body",
                 `String
                   ("Possible duplication detected. Refer to #"
                  ^ Int.to_string max_num) );
             ]))
    in
    let comment_header =
      Cohttp.Header.add_authorization
        (Cohttp.Header.init_with "accept" "application/vnd.github+json")
        (Cohttp.Auth.credential_of_string ("Bearer " ^ repo_key))
    in
    Client.post ~body:comment_body ~headers:comment_header
      (Uri.of_string
         ("https://api.github.com/repos/" ^ repo ^ "/issues/"
        ^ string_of_int issue_num ^ "/comments"))
    >>= fun (resp, body) ->
    let code = resp |> Response.status |> Code.code_of_status in
    Printf.eprintf "Response code: %d\n" code;
    Cohttp_lwt.Body.to_string body
  in
  let body = Lwt_main.run body in
  print_endline body

let main argv =
  let issue_num = int_of_string argv.(1) in
  let issue_contents = argv.(2) in
  let repo = argv.(3) in
  let rapid_key = argv.(4) in
  let repo_key = argv.(5) in
  let threshold =
    if Option.is_some (float_of_string_opt Sys.argv.(6)) then
      float_of_string Sys.argv.(6)
    else 0.20
  in
  assert (rapid_key <> "");
  let map = get_issues repo 1 IntMap.empty in
  let max_sim, max_num =
    find_max_sim issue_num issue_contents rapid_key threshold map
  in
  if max_sim > threshold then write_comment issue_num repo repo_key max_num
  else ()

let _ = main Sys.argv
