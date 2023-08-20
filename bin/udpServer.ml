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
    print_endline ("0x" ^ String.sub hex_string !i 2);
    print_endline (String.sub hex_string !i 2);
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
  print_endline "received lst = ";
  print_endline (String.concat " ; " lst);
  let udpMsg =
    match lst with
    | [ "subscribe"; topic ] -> SubscribeRequest topic
    | [ "unsubscribe"; topic ] -> UnsubscribeRequest topic
    | [ "publish"; topic; message ] ->
        print_endline ("Inside publish : " ^ topic ^ message);
        PublishRequest (topic, message)
    | [ "publish"; message ] -> DefPublishRequest message
    | [ "quit"; "your"; "server" ] -> CloseConnRequest
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
    print_endline ("Inside PublishRequest, topic: " ^ topic);
    print_endline ("Inside PublishRequest, message: " ^ message);
      let dev = Play.device () in
      let message = parse_hex_string message in
      print_endline ("Inside PublishRequest, message: " ^ (String.of_bytes message));
      let midi_message =
        Rtpmidi.UDP_SERIALIZER.deserialize (message)
      in
      print_endline (string_of_int midi_message.channel);
      print_endline (string_of_int midi_message.data1);
      print_endline (string_of_int midi_message.data2);
      print_endline (string_of_int midi_message.status_byte);
      print_endline (string_of_int midi_message.timestamp);
      print_endline "Calling write_midi_message";
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
  print_endline "Waiting for request";

  let buffer = Bytes.create 1024 in

  (* print_endline "just created buffer"; *)
  server_socket >>= fun server_socket ->
  (* print_endline "just got server_socket"; *)
  Lwt_unix.recvfrom server_socket buffer 0 1024 []
  >>= fun (num_bytes, client_address) ->
  (* print_endline "Received request"; *)
  let message = Bytes.sub_string buffer 0 num_bytes in

  (* print_endline ("Received message in handle_request: " ^ message); *)
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
      (* print_endline "Reply sent"; *)
      handle_request (Lwt.return server_socket)

(* This function create_server takes a server socket (sock) as input
   and initiates the handle_request process for that socket. *)
let create_server sock =
  (* print_endline "Creating server"; *)
  handle_request sock

(* This function create_socket creates a UDP socket, binds it to the
   listen_address and port, and returns the socket. *)
let create_socket () : Lwt_unix.file_descr Lwt.t =
  (* print_endline "Creating socket"; *)
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_DGRAM 0 in

  bind sock @@ ADDR_INET (listen_address, port) >>= fun () -> Lwt.return sock
