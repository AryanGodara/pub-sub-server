let play_note param_list () =
  (*TODO: Initialize Portmidi *)
  print_endline "Calling Midi.init ()\n";
  Midi.init ();

  (*TODO: List Devices  *)
  print_endline "Calling Midi.List_devices.list_devices ()\n";
  List_devices.list_devices () |> ignore;

  let dev = Midi.Device.create 1 in
  let channel = int_of_char param_list.(0) in
  let note = param_list.(1) in
  let volume = param_list.(2) in

  (* Send the note_on signal *)
  Midi.(write_output dev [ message_on ~note ~timestamp:0l ~volume ~channel () ]);

  (* Sleep for 2 seconds  *)
  Unix.sleepf 0.5;

  (* Send the note_off signal *)
  Midi.(
    write_output dev [ message_off ~note ~timestamp:0l ~volume ~channel () ]);

  Midi.Device.shutdown dev |> ignore;
  (* match res with
     | `Ok -> print_endline "Successfully shut down Midi device\n%!"
     | `Error e -> Printf.eprintf "Error shutting down Midi device: %s\n%!" e *)
  ()
