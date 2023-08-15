open Lwt.Infix
open TopicFilter
open Rtpmidi

let listen_address = Unix.inet_addr_loopback
let port = 9000
let string_to_char s = char_of_int @@ int_of_string s

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
      Play.play_note (Array.of_list [ '0'; char_of_int 60; char_of_int 127 ]) ();
      "Subscribed to " ^ topic
  | UnsubscribeRequest topic ->
      TOPIC_FILTER.removeSocket topic client_address;
      "Unsubscribed from " ^ topic
  | DefPublishRequest message ->
      let midiMessage  = Rtpmidi.UDP_SERIALIZER.deserialize (Bytes.of_string message) in
      let channel = MIDI_MESSAGE.channel midiMessage in
      let note = MIDI_MESSAGE.data1 midiMessage in
      let velocity = MIDI_MESSAGE.data2 midiMessage in
      let char_array = Array.of_list [ char_of_int channel; char_of_int note; char_of_int velocity ] in
      Play.play_note char_array ();

      (* let msg_list = Str.split_delim (Str.regexp ",") message in
      print_endline "msg_list = ";
      print_endline (String.concat " ; " msg_list);
      let _ = match msg_list with
      | [note; volume] ->
        let arrayList = Array.of_list [ '0'; string_to_char note; string_to_char volume ] in
        print_endline "arrayList = ";
        print_endline (String.concat " ; " (List.map (fun x -> String.make 1 x) (Array.to_list arrayList)));
        Play.play_note (arrayList) ();
      | _ -> ();
      in *)
      "Published on channel 0" ^ message
  | PublishRequest (topic, message) -> (
      let msg_list = Str.split_delim (Str.regexp ",") message in
      match msg_list with
      | [ _; _; _ ] ->
          let char_param_list = List.map string_to_char msg_list in
          Play.play_note (Array.of_list char_param_list) ();
          "Published on " ^ topic
      | _ -> "Invalid message")
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
