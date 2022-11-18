open! Core
open! Async

type err = { reason : string } [@@deriving sexp]

let count = ref 0

let cat reader _ =
  let rec loop_cat reader () =
    match%bind Pipe.read reader with
    | `Eof -> raise_s [%sexp "EOF", { reason = "fds" }]
    | `Ok _ ->
      count := !count + 1;
      loop_cat reader ()
  in
  Deferred.don't_wait_for (loop_cat reader ());
  Deferred.return ()
;;

let run () =
  let open Cohttp_async_websocket in
  let websocket_server =
    let handle_request ~inet:_ ~subprotocol:_ _request =
      return (Server.On_connection.create cat)
    in
    Server.create
      ~non_ws_request:(fun ~body:_ -> failwith "got a request that wasn't websocket!")
      handle_request
  in
  let%bind http_server =
    Cohttp_async.Server.create_expert
      ~max_connections:100
      ~backlog:100000
      (Tcp.Where_to_listen.of_port 8080)
      ~on_handler_error:(`Call (fun _ _ -> printf "%d\n" !count))
      websocket_server
  in
  let port = Cohttp_async.Server.listening_on http_server in
  print_int port;
  (* let url = Uri.of_string (sprintf "http://localhost:%d" port) in
     let%bind response, _reader, _writer =
       Cohttp_async_websocket.Client.create url >>| Or_error.ok_exn
     in
     let status = Cohttp_async.Response.status response in
     print_s [%message (status : Cohttp.Code.status_code)]; *)
  Deferred.never ()
;;

let () =
  Command.async ~summary:"An echo server" (Command.Param.return run) |> Command_unix.run
;;
