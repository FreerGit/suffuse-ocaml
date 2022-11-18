open! Core

module CurrencyPair = struct
  type t =
    { base : string
    ; quote : string
    }
  [@@deriving yojson, make, show]
end
