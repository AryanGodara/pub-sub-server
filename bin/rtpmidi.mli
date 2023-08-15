(* Module to handle all types of operations on MIDI messages:
   The rtpMIDI prodocol for UDP transfer , and the RTPMIDI protocol for conversion to portmidi compatible bytes *)
    module MIDI_MESSAGE : sig
      type t
  
      (* [t] stores the entire midi message; the idea is to use type b to serialize *)
      type b = STATUS_BYTE of Bytes.t | DATA_BYTE of Bytes.t
  
      (* Constructors *)
  
      val create :
        status:int -> channel:int -> data1:int -> data2:int -> timestamp:int -> t
  
      (* Getters *)
      val status : t -> int
      val channel : t -> int
      val data1 : t -> int
      val data2 : t -> int
      val timestamp : t -> int
      val valid_channel : int -> bool
    end
  
    (* This module is to convert the struct into different bytes to pass to portmidi library *)
    module PORTMIDI_SERIALIZER : sig end
  
    (* This module is to convert the struct into a single byte string which can be sent over UDP *)
    module UDP_SERIALIZER : sig
      type t = MIDI_MESSAGE.t
  
      val serialize : t -> bytes
      (** [serialize t] serializes a MIDI message [t] into a byte string *)
  
      val deserialize : bytes -> t
      (** [deserialize bytes] deserializes a byte string [bytes] into a MIDI message *)
    end
  
    val midi_to_bytes : MIDI_MESSAGE.t -> Bytes.t
    (** Convert a MIDI message to a byte string *)
  
    val bytes_to_midi : Bytes.t -> MIDI_MESSAGE.t
    (** Convert a byte string to a MIDI message *)