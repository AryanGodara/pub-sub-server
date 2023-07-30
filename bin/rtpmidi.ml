module type RTP_MIDI = sig
  type midi_message = int list

  val midi_to_bytes : midi_message -> Bytes.t
  (** Convert a MIDI message to a byte string *)

  val bytes_to_midi : Bytes.t -> midi_message
  (** Convert a byte string to a MIDI message *)
end

module RTPMIDI : RTP_MIDI = struct
  type midi_message = int list
  let midi_to_bytes (message : midi_message) : Bytes.t =
    let bytes = Bytes.create (List.length message) in
    List.iteri (fun i byte -> Bytes.set bytes i (Char.chr byte)) message;
    bytes

  let bytes_to_midi (bytes : Bytes.t) : midi_message =
    let message = ref [] in
    Bytes.iteri (fun _ byte -> message := !message @ [int_of_char byte]) bytes;
    !message
end