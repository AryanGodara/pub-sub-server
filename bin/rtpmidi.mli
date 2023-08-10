(* rtpmidi.mli *)

(* Define the types for MIDI messages *)
type midi_message = int array

(* Define the type for the RTP-MIDI packet *)
type rtpmidi_packet = {
  timestamp : int; (* Timestamp for the MIDI message *)
  sequence_number : int; (* Sequence number for packet ordering *)
  midi_data : midi_message; (* MIDI message data *)
}

(* Define the signature for the RTP-MIDI module *)
module type RTPMIDI = sig
  (* Initialize the RTP-MIDI session *)
  val init : unit -> unit

  (* Convert MIDI data to RTP-MIDI packet *)
  val midi_to_rtpmidi : midi_message -> rtpmidi_packet

  (* Convert RTP-MIDI packet to MIDI data *)
  val rtpmidi_to_midi : rtpmidi_packet -> midi_message

  (* Send a RTP-MIDI packet over the network *)
  val send_rtpmidi : rtpmidi_packet -> unit

  (* Receive a RTP-MIDI packet from the network *)
  val receive_rtpmidi : unit -> rtpmidi_packet option

  (* Close the RTP-MIDI session and release resources *)
  val close : unit -> unit
end

(* Define the signature for the MIDI data storage module *)
module type MidiDataStorage = sig
  (* Store a MIDI message *)
  val store_midi : midi_message -> unit

  (* Retrieve all stored MIDI messages *)
  val get_all_midi : unit -> midi_message list

  (* Clear all stored MIDI messages *)
  val clear_all_midi : unit -> unit
end
