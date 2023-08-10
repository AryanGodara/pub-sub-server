(** This module provides a UDP server that listens for incoming messages and sends appropriate responses back to clients. *)

(** The function that handles incoming messages and sends appropriate responses back to clients. *)
val handle_request : Lwt_unix.file_descr Lwt.t -> unit Lwt.t

(** The function that creates a UDP server and initiates the `handle_request` process for that server. *)
val create_server : Lwt_unix.file_descr Lwt.t -> unit Lwt.t

(** The function that creates a UDP socket, binds it to the listen address and port, and returns the socket. *)
val create_socket : unit -> Lwt_unix.file_descr Lwt.t