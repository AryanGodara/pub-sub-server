(** This module provides a topic filter that allows adding, removing, and getting Unix sockets by topic. *)

(** The signature of the `TOPIC_FILTER` module type. *)
module TOPIC_FILTER : sig
  (** Adds a Unix socket to the given topic. *)
  val addSocket : string -> Unix.sockaddr -> unit

  (** Removes a Unix socket from the given topic. *)
  val removeSocket : string -> Unix.sockaddr -> unit

  (** Gets a list of Unix sockets for the given topic. *)
  val getSockets : string -> Unix.sockaddr list
end
  
(** The `TOPIC_FILTER` module. *)