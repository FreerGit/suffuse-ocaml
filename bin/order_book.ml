open! Core
open! Async
open! Exchange
open! Support_intf

let read_loop table supports =
  Clock.run_at_intervals (Time.Span.of_sec 20.0) (fun () ->
    List.iter supports ~f:(
      fun (module I : Ws_instance) -> 
        subscribe table I.Ws.exchange_key "{\"op\":\"ping\"}" |> don't_wait_for ));
    let rec loop () = 
      let%bind _ = Async.Deferred.List.iter ~how:`Parallel supports ~f:(fun (module I : Ws_instance) -> 
        let%bind str = I.Ws.read I.this in
        printf "\027[32m%-8s \027[0m| %s\n" (Exchange_Key.show I.Ws.exchange_key) str;
        Deferred.return ()
        ) in
        loop ()
      in
      don't_wait_for (loop ());
      return ()

let sub () = "{\"op\": \"subscribe\", \"args\": [\"orderBookL2_25.BTCUSDT\"]}"

let run () =
  let%bind supports = Deferred.all [ connect (module Bybit.Ws); connect (module Bitmex.Ws) ] in
  let dispatch_table = build_exchange_dispatch_table supports in 
  let%bind _ = Deferred.all @@ List.map supports ~f:(
    fun (module I : Ws_instance) -> subscribe dispatch_table I.Ws.exchange_key (sub ())) in
  let%bind _ = read_loop dispatch_table supports in
  Deferred.never ()
;;

let () =
  Command.async ~summary:"An echo server" (Command.Param.return run) |> Command_unix.run
;; 

