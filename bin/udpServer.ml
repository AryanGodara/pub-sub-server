open Lwt.Infix
open TopicFilter

let listen_address = Unix.inet_addr_loopback
let port = 9000

let string_to_char s = char_of_int @@ int_of_string s

type pubsubmessage = 
  | SubscribeRequest of string
  | UnsubscribeRequest of string
  | PublishRequest of string * string
(* 
msg format:
Subscribe <topic>
Unsubscribe <topic>
Publish <topic> <message>

message format:
rtp-midi format -> byte string (Use it to send midi messages/ receive etc.)
Deserialize the byte string into a format that can be sent to a midi device.
*)

let handle_message msg client_address =
  let lst = Str.split_delim (Str.regexp " ") msg in
  match lst with
  | ["subscribe"; topic] -> SubscribeRequest (topic)
  | ["unsubscribe"; topic] -> UnsubscribeRequest (topic)
  | ["publish"; topic; message] -> PublishRequest (topic, message)
  | _ -> failwith "Invalid pubsubmessage format"

  (* match param_list with
  | "Subscribe" :: topic :: _ -> 
    TOPIC_FILTER.addSocket topic client_address;
    (* print_endline ("All the clients subscribed to " ^ topic ^ " are: "); *)
    (* let client_list = TOPIC_FILTER.getSockets topics; *)
    (* List.iter (fun client -> print_endline (string_of_inet_addr client)) client_list; *)
    "Subscribed to " ^ topic
  | "Subscribe" :: _ -> "Invalid Message"
  | "Unsubscribe" :: topic :: _ ->
    TOPIC_FILTER.removeSocket topic client_address;
    "Unsubscribed from " ^ topic
  | "Unsubscribe" :: _ -> "Invalid Message"
  | "Publish"  :: topic :: message :: [] ->
    let msg_list = Str.split_delim (Str.regexp " ") message in
      match msg_list with
      | [ _; _; _ ] as msg_list ->
          | "Publish" :: topic :: message :: [] ->
            let msg_list = Str.split_delim (Str.regexp " ") message in
            begin match msg_list with
            | [ _; _; _ ] ->
              let char_param_list = List.map string_to_char msg_list in
              Play.play_note (Array.of_list char_param_list) ();
              "Published on " ^ topic
            | _ -> "Invalid message"
            end
          | "Publish" :: _ -> "Invalid message"
              let msg_list = Str.split_delim (Str.regexp " ") message in
              begin match msg_list with
              | [ _; _; _ ] as msg_list ->
                let char_param_list = List.map string_to_char msg_list in
                Play.play_note (Array.of_list char_param_list) ();
                "Published on " ^ topic
              | _ -> "Invalid message"
              end
            | "Publish" :: _ -> "Invalid message"
            | _ -> "Invalid message"
      | _ -> ();
    "Published on " ^ topic
  | "Publish" :: [] -> "Invalid Message"
  | _ -> "Invalid message" *)

(* This function handle_request takes a server socket (server_socket)
   as input and recursively listens for incoming UDP packets from
   clients. It processes the received messages using the handle_message
   function and sends appropriate responses back to the clients. *)
let rec handle_request server_socket =
  print_endline "Waiting for request";

  let buffer = Bytes.create 1024 in
  print_endline "just created buffer";

  server_socket >>= fun server_socket ->
  print_endline "just got server_socket";

  Lwt_unix.recvfrom server_socket buffer 0 1024 []
  >>= fun (num_bytes, client_address) ->
  print_endline "Received request";

  let message = Bytes.sub_string buffer 0 num_bytes in
  print_endline ("Received message in handle_request: " ^ message);

  let reply = handle_message message client_address in
  match reply with
  | "quit" ->
      print_endline "Quitting Server...";
      Lwt_unix.sendto server_socket (Bytes.of_string reply) 0
        (String.length reply) [] client_address
      >>= fun _ -> Lwt.return ()
  | _ ->
      print_endline ("Replying with: " ^ reply);

      Lwt_unix.sendto server_socket (Bytes.of_string reply) 0
        (String.length reply) [] client_address
      >>= fun _ ->
      print_endline "Reply sent";

      handle_request (Lwt.return server_socket)

(* This function create_server takes a server socket (sock) as input
   and initiates the handle_request process for that socket. *)
let create_server sock =
  print_endline "Creating server";
  handle_request sock

(* This function create_socket creates a UDP socket, binds it to the
   listen_address and port, and returns the socket. *)
let create_socket () : Lwt_unix.file_descr Lwt.t =
  print_endline "Creating socket";

  let open Lwt_unix in
  let sock = socket PF_INET SOCK_DGRAM 0 in

  bind sock @@ ADDR_INET (listen_address, port) >>= fun () -> Lwt.return sock
