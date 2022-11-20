open! Core
open! Async
open! Exchange
open! Support_intf


(* let loopy l =
  Clock.run_at_intervals (Time.Span.of_sec 20.0) (fun () ->
    List.iter l ~f:(fun x -> Bybit.Ws.subsribe "{\"op\":\"ping\"}" x |> don't_wait_for));
  let rec loop_h l () =
    let%bind _ = Async.Deferred.List.iter ~how:`Parallel l ~f:(fun x -> 
      (let%bind (str, id) = Bybit.Ws.read x in
      printf "@@ %d @@ %s\n" id str;
      Deferred.return ())
      ) in 
    loop_h l ()
  in
  Deferred.don't_wait_for (loop_h l ());
  Deferred.return ()
;;
let%bind _ = loopy ws_impls in *)

(* let sub () = "{\"op\": \"subscribe\", \"args\": [\"orderBookL2_25.BTCUSDT\"]}"

let run () =
  (* let open! Exchange in *)
  let ws_impls = Deferred.all @@ [connect (; Impl_2.connect 2] in
  (* let%bind l = Deferred.all @@ List.init 20 ~f:(fun x -> Bybit.Ws.connect x) in *)
  let%bind _ = Deferred.all @@ List.map ws_impls ~f:(fun x -> Impl_General.subsribe (sub ()) x) in
  Deferred.never ()
;;

let () =
  Command.async ~summary:"An echo server" (Command.Param.return run) |> Command_unix.run
;; *)

let _ = Deferred.all [ connect (module Bybit.Ws) 1; connect (module Bitmex.Ws) 2 ]
