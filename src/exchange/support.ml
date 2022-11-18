open! Core
open! Async

module type Support = sig
  type t

  val connect : int -> t Deferred.t
  val subsribe : string -> t -> unit Deferred.t
  val read : t -> (string *  int) Deferred.t
  (* val event_loop : (string Pipe.Reader.t * string Pipe.Writer.t) Deferred.t *)
end
