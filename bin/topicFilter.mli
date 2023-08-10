(** This module provides a topic filter that allows adding, removing, and
    getting Unix sockets by topic. *)

(** The signature of the `TOPIC_FILTER` module type. *)
module TOPIC_FILTER : sig
  val addSocket : string -> Unix.sockaddr -> unit
  (** Adds a Unix socket to the given topic. *)

  val removeSocket : string -> Unix.sockaddr -> unit
  (** Removes a Unix socket from the given topic. *)

  val getSockets : string -> Unix.sockaddr list
  (** Gets a list of Unix sockets for the given topic. *)
end

(** The `TOPIC_FILTER` module. *)
