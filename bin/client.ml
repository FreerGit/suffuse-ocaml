open! Core
open! Async
open! Cohttp_async_websocket

let loopy reader writer =
  let%bind _ =
    Pipe.write writer "{\"op\": \"subscribe\", \"args\": [\"liquidation.BTCUSDT\"]}"
  in
  Clock.run_at_intervals (Time.Span.of_sec 20.0) (fun () ->
    don't_wait_for @@ Pipe.write writer "{\"op\":\"ping\"}");
  let rec loop_h reader writer () =
    match%bind Pipe.read reader with
    | `Eof -> raise_s [%sexp "EOF", { reason = "fds" }]
    | `Ok t ->
      print_endline t;
      loop_h reader writer ()
  in
  Deferred.don't_wait_for (loop_h reader writer ());
  Deferred.return ()
;;

let run () =
  let uri = Uri.of_string "wss://stream.bytick.com/realtime_public" in
  match%bind Client.create uri with
  | Ok (res, r, w) ->
    print_endline "fdsfddddddd";
    Cohttp.Response.sexp_of_t res |> Sexp.to_string |> printf "%s\n";
    let%bind _ = loopy r w in
    Deferred.never ()
    (* let rec loop w = *)
    (* loop (); *)
  | Error e ->
    print_endline @@ Error.to_string_hum e;
    print_endline "fdsfa";
    Deferred.unit
;;

let () =
  Command.async ~summary:"An echo server" (Command.Param.return run) |> Command_unix.run
;;
