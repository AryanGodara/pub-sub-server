(* Module to handle all types of operations on MIDI messages:
   The rtpMIDI prodocol for UDP transfer , and the RTPMIDI protocol for conversion to portmidi compatible bytes *)
   module type RTP_MIDI = sig
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
      val deserialize : bytes -> t
    end
  
    val midi_to_bytes : MIDI_MESSAGE.t -> Bytes.t
    (** Convert a MIDI message to a byte string *)
  
    val bytes_to_midi : Bytes.t -> MIDI_MESSAGE.t
    (** Convert a byte string to a MIDI message *)
  end
  
  module RTPMIDI : RTP_MIDI = struct
    module MIDI_MESSAGE = struct
      type t = {
        status : int;
        channel : int;
        data1 : int;
        data2 : int;
        timestamp : int;
      }
  
      type b = STATUS_BYTE of Bytes.t | DATA_BYTE of Bytes.t
  
      let create ~status ~channel ~data1 ~data2 ~timestamp =
        { status; channel; data1; data2; timestamp }
  
      let status message = message.status
      let channel message = message.channel
      let data1 message = message.data1
      let data2 message = message.data2
      let timestamp message = message.timestamp
      let valid_channel channel = channel >= 0 && channel <= 15
    end
  
    module PORTMIDI_SERIALIZER = struct end
  
    module UDP_SERIALIZER = struct
      (* open MIDI_MESSAGE *)
  
      type t = MIDI_MESSAGE.t
  
      let serialize t =
        let bytes = Bytes.create 4 in
        Bytes.set bytes 0 (Char.chr t.MIDI_MESSAGE.status);
        Bytes.set bytes 1 (Char.chr t.MIDI_MESSAGE.channel);
        Bytes.set bytes 2 (Char.chr t.MIDI_MESSAGE.data1);
        Bytes.set bytes 3 (Char.chr t.MIDI_MESSAGE.data2);
        bytes
  
      let deserialize bytes =
        if Bytes.length bytes <> 4 then failwith "Invalid MIDI message bytes";
        let status = int_of_char (Bytes.get bytes 0) in
        let channel = int_of_char (Bytes.get bytes 1) in
        let data1 = int_of_char (Bytes.get bytes 2) in
        let data2 = int_of_char (Bytes.get bytes 3) in
        MIDI_MESSAGE.create ~status ~channel ~data1 ~data2 ~timestamp:0
    end
  
    let midi_to_bytes (message : MIDI_MESSAGE.t) : Bytes.t =
      UDP_SERIALIZER.serialize message
  
    let bytes_to_midi (bytes : Bytes.t) : MIDI_MESSAGE.t =
      UDP_SERIALIZER.deserialize bytes
  end
  