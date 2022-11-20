open! Core
open! Async

(* https://dev.realworldocaml.org/first-class-modules.html#dispatching-to-multiple-query-handlers *)


module type Support = sig
  type t

  val connect : int -> t Deferred.t
  val subsribe : string -> t -> unit Deferred.t
  val read : t -> (string *  int) Deferred.t
end

module type Ws_instane = sig
  module Ws : Support

  val this : Ws.t

end

let connect (type a) (module Ws : Support with type t = a) n =
  let%bind this = Ws.connect n in
  return
    (module struct
      module Ws = Ws

      let this = this
    end : Ws_instane)
;;


(* val event_loop : (string Pipe.Reader.t * string Pipe.Writer.t) Deferred.t *)