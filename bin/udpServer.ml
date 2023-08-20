open Lwt.Infix
open TopicFilter

let parse_hex_string hex_string =
  let length = String.length hex_string in
  if length mod 2 <> 0 then failwith "Invalid hex string length";
  let bytes = Bytes.create (length / 2) in
  let i = ref 0 in
  while !i < length do
    let byte = int_of_string ("0x" ^ String.sub hex_string !i 2) |> char_of_int in
    Bytes.set bytes (!i / 2) byte;
    (* print_endline ("0x" ^ String.sub hex_string !i 2); *)
    (* print_endline (String.sub hex_string !i 2); *)
    i := !i + 2
  done;
  bytes

let _parse_hex_string_of_variable_length hex_string =
  let length = String.length hex_string in
  if length mod 2 <> 0 then failwith "Invalid hex string length";
  let bytes = Bytes.create (length / 2) in
  let i = ref 0 in
  while !i < length do
    let byte =
      if !i + 1 < length then
        int_of_string ("0x" ^ String.sub hex_string !i 2) |> char_of_int
      else
        int_of_string ("0x" ^ String.sub hex_string !i 1 ^ "0") |> char_of_int
    in
    Bytes.set bytes (!i / 2) byte;
    i := !i + 2
  done;
  bytes

let listen_address = Unix.inet_addr_loopback
let port = 9000

type pubsubmessage =
  | SubscribeRequest of string
  | UnsubscribeRequest of string
  | PublishRequest of string * string
  | DefPublishRequest of string
  | CloseConnRequest
  | InvalidRequest of string

let handle_message msg client_address =
  let lst = Str.split_delim (Str.regexp " ") msg in
  let udpMsg =
    match lst with
    | [ "subscribe"; topic ] -> SubscribeRequest topic
    | [ "unsubscribe"; topic ] -> UnsubscribeRequest topic
    | [ "publish"; topic; message ] -> PublishRequest (topic, message)
    | [ "publish"; message ] -> DefPublishRequest message
    | [ "quit" ] -> CloseConnRequest
    | _ -> InvalidRequest "Invalid pubsubmessage format"
  in
  match udpMsg with
  | SubscribeRequest topic ->
      TOPIC_FILTER.addSocket topic client_address;
      "Subscribed to " ^ topic
  | UnsubscribeRequest topic ->
      TOPIC_FILTER.removeSocket topic client_address;
      "Unsubscribed from " ^ topic
  | DefPublishRequest message -> "Published on channel 0" ^ message
  | PublishRequest (topic, message) ->
      let dev = Play.device () in
      let message = parse_hex_string message in
      let midi_message =
        Rtpmidi.UDP_SERIALIZER.deserialize (message)
      in
      Play.write_midi_message dev midi_message;
      Midi.Device.shutdown dev |> ignore;
      "Published " ^ (String.of_bytes message) ^ " on " ^ topic
  | CloseConnRequest -> "quit"
  | InvalidRequest msg -> msg

(* This function handle_request takes a server socket (server_socket)
   as input and recursively listens for incoming UDP packets from
   clients. It processes the received messages using the handle_message
   function and sends appropriate responses back to the clients. *)
let rec handle_request server_socket =
  let buffer = Bytes.create 1024 in
  server_socket >>= fun server_socket ->
  Lwt_unix.recvfrom server_socket buffer 0 1024 []
  >>= fun (num_bytes, client_address) ->
  let message = Bytes.sub_string buffer 0 num_bytes in
  let reply = handle_message message client_address in
  match reply with
  | "quit" ->
      print_endline "Quitting Server...";
      Lwt_unix.sendto server_socket (Bytes.of_string reply) 0
        (String.length reply) [] client_address
      >>= fun _ -> Lwt.return ()
  | _ ->
      Lwt_unix.sendto server_socket (Bytes.of_string reply) 0
        (String.length reply) [] client_address
      >>= fun _ ->
      handle_request (Lwt.return server_socket)

(* This function create_server takes a server socket (sock) as input
   and initiates the handle_request process for that socket. *)
let create_server sock =
  handle_request sock

(* This function create_socket creates a UDP socket, binds it to the
   listen_address and port, and returns the socket. *)
let create_socket () : Lwt_unix.file_descr Lwt.t =
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_DGRAM 0 in

  bind sock @@ ADDR_INET (listen_address, port) >>= fun () -> Lwt.return sock
