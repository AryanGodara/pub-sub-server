type midi_type =
  | NOTE_OFF
  | NOTE_ON
  | POLY_PRESSURE
  | CONTROL_CHANGE
  | PROGRAM_CHANGE
  | CHANNEL_PRESSURE
  | PITCH_BEND
  | SYSTEM_EXCLUSIVE
  | TIME_CODE
  | SONG_POSITION
  | SONG_SELECT
  | TUNE_REQUEST
  | END_OF_EXCLUSIVE
  | TIMING_CLOCK
  | START
  | CONTINUE
  | STOP
  | ACTIVE_SENSING
  | SYSTEM_RESET

module MIDI_MESSAGE : sig
  type t = {
    message_type : midi_type;
    status_byte : int;
    channel : int;
    data1 : int;
    data2 : int;
    timestamp : int;
  }

  val message_type : t -> midi_type
  (** Returns the MIDI message type of the given message *)

  val create :
    message_type:midi_type ->
    channel:int ->
    data1:int ->
    data2:int ->
    timestamp:int ->
    t
  (** Creates a new MIDI message with the given message type, channel, data
      bytes, and timestamp *)
end

module UDP_SERIALIZER : sig
  val serialize : MIDI_MESSAGE.t -> Bytes.t
  (** Serializes the given MIDI message to a byte array *)

  val deserialize : Bytes.t -> MIDI_MESSAGE.t
  (** Deserializes the given byte array to a MIDI message *)
end

type hardcoded_midi_message =
  | NOTE_OFF of {
      note : char;
      velocity : char;
      channel : int;
      timestamp : int32;
    }
  | NOTE_ON of {
      note : char;
      velocity : char;
      channel : int;
      timestamp : int32;
    }
  | POLY_PRESSURE of {
      note : char;
      pressure : char;
      channel : int;
      timestamp : int32;
    }
  | CONTROL_CHANGE of {
      controller : char;
      value : char;
      channel : int;
      timestamp : int32;
    }
  | PROGRAM_CHANGE of { program : char; channel : int; timestamp : int32 }
  | CHANNEL_PRESSURE of { pressure : char; channel : int; timestamp : int32 }
  | PITCH_BEND of { value : int; channel : int; timestamp : int32 }
  | SYSTEM_EXCLUSIVE of { data : int; timestamp : int32 }
  | TIME_CODE of { value : char; timestamp : int32 }
  | SONG_POSITION of { position : int; timestamp : int32 }
  | SONG_SELECT of { song : char; timestamp : int32 }
  | TUNE_REQUEST of { timestamp : int32 }
  | END_OF_EXCLUSIVE of { timestamp : int32 }
  | TIMING_CLOCK of { timestamp : int32 }
  | START of { timestamp : int32 }
  | CONTINUE of { timestamp : int32 }
  | STOP of { timestamp : int32 }
  | ACTIVE_SENSING of { timestamp : int32 }
  | SYSTEM_RESET of { timestamp : int32 }
      (** Represents a MIDI message with specific data values *)

val convert_to_hardcoded_midi_message : MIDI_MESSAGE.t -> hardcoded_midi_message
(** Converts the given MIDI message to a hardcoded MIDI message *)
