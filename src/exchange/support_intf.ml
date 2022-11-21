open! Core
open! Async

module Exchange_Key = struct
  type t =
    | Bybit
    | Bitmex
  [@@deriving hash, compare, sexp]
end
(* https://dev.realworldocaml.org/first-class-modules.html#dispatching-to-multiple-query-handlers *)

module type Support = sig
  type t

  val url : string
  val exchange_key : Exchange_Key.t

  val connect : int -> t Deferred.t
  val subscribe : string -> t -> unit Deferred.t
  val read : t -> (string * int) Deferred.t
end

module type Ws_instance = sig
  module Ws : Support

  val this : Ws.t
end

let connect (type a) (module Ws : Support with type t = a) n =
  let%bind this = Ws.connect n in
  return
    (module struct
      module Ws = Ws

      let this = this
    end : Ws_instance)
;;

let subscribe (type a) (module Ws : Support with type t = a) url self =
  let%bind u = Ws.subscribe url self in
  return u
;;



let build_exchange_dispatch_table handlers =
  let table = Hashtbl.create (module Exchange_Key) in
  List.iter handlers ~f:(fun ((module I : Ws_instance) as instance) ->
    Hashtbl.set table ~key:I.Ws.exchange_key ~data:instance);
  table
;;

let dispatch dispatch_table key url =
  match (Hashtbl.find dispatch_table key) with
  | None -> raise_s [%message "Unable to find the given exchange in table"]
  | Some ((module I : Ws_instance)) -> I.Ws.subscribe url I.this

(* val event_loop : (string Pipe.Reader.t * string Pipe.Writer.t) Deferred.t *)
