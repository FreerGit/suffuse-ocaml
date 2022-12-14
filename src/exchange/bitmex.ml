open! Core
open! Async
include Support_intf

module Ws : Support = struct
  open! Cohttp_async_websocket

  let url = "wss://stream.bytick.com/realtime_public"

  type t =
    { reader : string Pipe.Reader.t
    ; writer : string Pipe.Writer.t
    }

  let exchange_key = Exchange_Key.Bitmex

  let connect =
    match%bind Client.create (Uri.of_string url) with
    | Ok (_resp, reader, writer) -> Deferred.return { reader; writer }
    | Error e -> raise_s @@ Error.sexp_of_t e
  ;;

  let subscribe sub t = Pipe.write t.writer sub

  let read t =
    match%bind Pipe.read t.reader with
    | `Eof -> raise_s [%sexp "EOF", { reason = "fds" }]
    | `Ok str -> Deferred.return str
  ;;
end
(* let connect =  *)

(* module Opcode = struct
  type t =
    | Ping [@name "ping"]
    | Pong [@name "pong"]
    | Subscribe [@name "subscribe"]
  [@@deriving yojson]
end

module Topic = struct
  type t =
    | Liquidation
    | Orderbook25
    | Trade

  let of_string t =
    match t with
    | Liquidation -> "liquidation"
    | Orderbook25 -> "orderBookL2_25"
    | Trade -> "trade"
  ;;
end *)
