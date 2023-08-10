let main () =
  (*TODO: Initialize Portmidi *)
  print_endline "Calling Midi.init ()\n";
  Midi.init ();

  (*TODO: List Devices  *)
  print_endline "Calling Midi.List_devices.list_devices ()\n";
  List_devices.list_devices () |> ignore;
  ()

let () =
  print_endline "Launching MIDI Server...";
  main ();

  print_endline "Launching UDP Server...";

  print_endline "Setting up Logs...";
  let () = Logs.set_reporter (Logs.format_reporter ()) in
  let () = Logs.set_level (Some Logs.Info) in

  print_endline "Creating UDP Server...";
  let server_socket = UdpServer.create_socket () in
  Lwt_main.run UdpServer.(create_server server_socket)
