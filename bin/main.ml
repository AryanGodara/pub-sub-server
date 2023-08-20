let main () =
  Midi.init ();
  List_devices.list_devices () |> ignore;
  ()

let () =
  print_endline "Launching MIDI Server...";
  main ();

  print_endline "Setting up Logs...";
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  let () = Logs.set_level (Some Logs.Info) in

  print_endline "Creating UDP Server...";
  let server_socket = UdpServer.create_socket () in
  Lwt_main.run UdpServer.(create_server server_socket)
