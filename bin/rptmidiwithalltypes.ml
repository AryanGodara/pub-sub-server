(* Enum type for MIDI message types *)
type midi_message_type =
  | NoteOff
  | NoteOn
  | PolyphonicKeyPressure
  | ControlChange
  | ProgramChange
  | ChannelPressure
  | PitchBend
  | SystemExclusive
  | TimeCode
  | SongPosition
  | SongSelect
  | TuneRequest
  | EndOfExclusive
  | TimingClock
  | Start
  | Continue
  | Stop
  | ActiveSensing
  | SystemReset

(* Module to handle all types of operations on MIDI messages:
   The rtpMIDI prodocol for UDP transfer , and the RTPMIDI protocol for conversion to portmidi compatible bytes *)
module MIDI_MESSAGE = struct
  type t = {
    message_type : midi_message_type;
    channel : int;
    data1 : int;
    data2 : int;
    timestamp : int;
  }

  let create ~message_type ~channel ~data1 ~data2 ~timestamp =
    { message_type; channel; data1; data2; timestamp }

  let message_type t = t.message_type
  let channel t = t.channel
  let data1 t = t.data1
  let data2 t = t.data2
  let timestamp t = t.timestamp
end

(* This module is to convert the struct into different bytes to pass to portmidi library *)
module PORTMIDI_SERIALIZER = struct
  let serialize (message : MIDI_MESSAGE.t) : Bytes.t =
    let status_byte =
      (match message.message_type with
      | NoteOff -> 0x80
      | NoteOn -> 0x90
      | PolyphonicKeyPressure -> 0xA0
      | ControlChange -> 0xB0
      | ProgramChange -> 0xC0
      | ChannelPressure -> 0xD0
      | PitchBend -> 0xE0
      | SystemExclusive -> 0xF0
      | TimeCode -> 0xF1
      | SongPosition -> 0xF2
      | SongSelect -> 0xF3
      | TuneRequest -> 0xF6
      | EndOfExclusive -> 0xF7
      | TimingClock -> 0xF8
      | Start -> 0xFA
      | Continue -> 0xFB
      | Stop -> 0xFC
      | ActiveSensing -> 0xFE
      | SystemReset -> 0xFF)
      lor message.channel
    in

    let data1_byte = Char.chr message.data1 in
    let data2_byte = Char.chr message.data2 in
    let bytes =
      match message.message_type with
      | NoteOff ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | NoteOn ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | PolyphonicKeyPressure ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | ControlChange ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | ProgramChange ->
          Bytes.of_string
            (Printf.sprintf "%c%c" (char_of_int status_byte) data1_byte)
      | ChannelPressure ->
          Bytes.of_string
            (Printf.sprintf "%c%c" (char_of_int status_byte) data1_byte)
      | PitchBend ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | SystemExclusive -> failwith "System Exclusive messages not supported"
      | TimeCode -> failwith "Time Code messages not supported"
      | SongPosition -> failwith "Song Position messages not supported"
      | SongSelect -> failwith "Song Select messages not supported"
      | TuneRequest -> failwith "Tune Request messages not supported"
      | EndOfExclusive -> failwith "End of Exclusive messages not supported"
      | TimingClock -> failwith "Timing Clock messages not supported"
      | Start -> failwith "Start messages not supported"
      | Continue -> failwith "Continue messages not supported"
      | Stop -> failwith "Stop messages not supported"
      | ActiveSensing -> failwith "Active Sensing messages not supported"
      | SystemReset -> failwith "System Reset messages not supported"
    in
    bytes
end

(* This module is to convert the struct into a single byte string which can be sent over UDP *)
module UDP_SERIALIZER : sig
  type t = MIDI_MESSAGE.t

  val serialize : t -> Bytes.t
  (** [serialize t] serializes a MIDI message [t] into a byte string *)

  val deserialize : Bytes.t -> t
  (** [deserialize bytes] deserializes a byte string [bytes] into a MIDI message *)
end = struct
  type t = MIDI_MESSAGE.t

  let serialize (message : MIDI_MESSAGE.t) : Bytes.t =
    let status_byte =
      (match message.message_type with
      | NoteOff -> 0x80
      | NoteOn -> 0x90
      | PolyphonicKeyPressure -> 0xA0
      | ControlChange -> 0xB0
      | ProgramChange -> 0xC0
      | ChannelPressure -> 0xD0
      | PitchBend -> 0xE0
      | SystemExclusive -> 0xF0
      | TimeCode -> 0xF1
      | SongPosition -> 0xF2
      | SongSelect -> 0xF3
      | TuneRequest -> 0xF6
      | EndOfExclusive -> 0xF7
      | TimingClock -> 0xF8
      | Start -> 0xFA
      | Continue -> 0xFB
      | Stop -> 0xFC
      | ActiveSensing -> 0xFE
      | SystemReset -> 0xFF)
      lor message.channel
    in
    let data1_byte = Char.chr message.data1 in
    let data2_byte = Char.chr message.data2 in
    let bytes =
      match message.message_type with
      | NoteOff ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | NoteOn ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | PolyphonicKeyPressure ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | ControlChange ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | ProgramChange ->
          Bytes.of_string
            (Printf.sprintf "%c%c" (char_of_int status_byte) data1_byte)
      | ChannelPressure ->
          Bytes.of_string
            (Printf.sprintf "%c%c" (char_of_int status_byte) data1_byte)
      | PitchBend ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (char_of_int status_byte) data1_byte
               data2_byte)
      | SystemExclusive -> failwith "System Exclusive messages not supported"
      | TimeCode -> failwith "Time Code messages not supported"
      | SongPosition -> failwith "Song Position messages not supported"
      | SongSelect -> failwith "Song Select messages not supported"
      | TuneRequest -> failwith "Tune Request messages not supported"
      | EndOfExclusive -> failwith "End of Exclusive messages not supported"
      | TimingClock -> failwith "Timing Clock messages not supported"
      | Start -> failwith "Start messages not supported"
      | Continue -> failwith "Continue messages not supported"
      | Stop -> failwith "Stop messages not supported"
      | ActiveSensing -> failwith "Active Sensing messages not supported"
      | SystemReset -> failwith "System Reset messages not supported"
    in
    bytes

  let deserialize (bytes : Bytes.t) : t =
    let status_byte = Char.code (Bytes.get bytes 0) in
    let message_type =
      match status_byte land 0xF0 with
      | 0x80 -> NoteOff
      | 0x90 -> NoteOn
      | 0xA0 -> PolyphonicKeyPressure
      | 0xB0 -> ControlChange
      | 0xC0 -> ProgramChange
      | 0xD0 -> ChannelPressure
      | 0xE0 -> PitchBend
      | 0xF0 -> SystemExclusive
      | 0xF1 -> TimeCode
      | 0xF2 -> SongPosition
      | 0xF3 -> SongSelect
      | 0xF6 -> TuneRequest
      | 0xF7 -> EndOfExclusive
      | 0xF8 -> TimingClock
      | 0xFA -> Start
      | 0xFB -> Continue
      | 0xFC -> Stop
      | 0xFE -> ActiveSensing
      | 0xFF -> SystemReset
      | _ -> failwith "Invalid message type"
    in
    let channel = status_byte land 0x0F in
    let data1 = Char.code (Bytes.get bytes 1) in
    let data2 = Char.code (Bytes.get bytes 2) in
    let timestamp = 0 in
    MIDI_MESSAGE.create ~message_type ~channel ~data1 ~data2 ~timestamp

  let deserialize (bytes : Bytes.t) : t =
    let status_byte = Char.code (Bytes.get bytes 0) in
    let message_type =
      match status_byte land 0xF0 with
      | 0x80 -> NoteOff
      | 0x90 -> NoteOn
      | 0xA0 -> PolyphonicKeyPressure
      | 0xB0 -> ControlChange
      | 0xC0 -> ProgramChange
      | 0xD0 -> ChannelPressure
      | 0xE0 -> PitchBend
      | 0xF0 ->
          if status_byte = 0xF0 then SystemExclusive
          else if status_byte = 0xF7 then EndOfExclusive
          else failwith "Invalid message type"
      | 0xF1 -> TimeCode
      | 0xF2 -> SongPosition
      | 0xF3 -> SongSelect
      | 0xF6 -> TuneRequest
      | 0xF8 -> TimingClock
      | 0xFA -> Start
      | 0xFB -> Continue
      | 0xFC -> Stop
      | 0xFE -> ActiveSensing
      | 0xFF -> SystemReset
      | _ -> failwith "Invalid message type"
    in
    let channel = status_byte land 0x0F in
    let data1 = Char.code (Bytes.get bytes 1) in
    let data2 =
      if message_type = ProgramChange || message_type = ChannelPressure then 0
      else Char.code (Bytes.get bytes 2)
    in
    let timestamp = 0 in
    MIDI_MESSAGE.create ~message_type ~channel ~data1 ~data2 ~timestamp
end

let midi_to_bytes (message : MIDI_MESSAGE.t) : Bytes.t =
  UDP_SERIALIZER.serialize message

module MIDI_MESSAGE = struct
  type t = {
    message_type : midi_message_type;
    channel : int;
    data1 : int;
    data2 : int;
    timestamp : int;
  }

  let create ~message_type ~channel ~data1 ~data2 ~timestamp =
    { message_type; channel; data1; data2; timestamp }

  let message_type t = t.message_type
  let channel t = t.channel
  let data1 t = t.data1
  let data2 t = t.data2
  let timestamp t = t.timestamp
  let valid_channel channel = channel >= 0 && channel <= 15
  let previous_status : char option ref = ref None

  let serialize (message : t) : Bytes.t =
    let channel_byte = char_of_int (0x0F land message.channel) in
    let data1_byte = char_of_int message.data1 in
    let data2_byte = char_of_int message.data2 in
    let bytes =
      match message.message_type with
      | NOTE_OFF ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0x80 lor message.channel))
               data1_byte data2_byte)
      | NOTE_ON ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0x90 lor message.channel))
               data1_byte data2_byte)
      | POLY_PRESSURE ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xA0 lor message.channel))
               data1_byte data2_byte)
      | CONTROL_CHANGE ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xB0 lor message.channel))
               data1_byte data2_byte)
      | PROGRAM_CHANGE ->
          Bytes.of_string
            (Printf.sprintf "%c%c"
               (char_of_int (0xC0 lor message.channel))
               data1_byte)
      | CHANNEL_PRESSURE ->
          Bytes.of_string
            (Printf.sprintf "%c%c"
               (char_of_int (0xD0 lor message.channel))
               data1_byte)
      | PITCH_BEND ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xE0 lor message.channel))
               data1_byte data2_byte)
      | SYSTEM_EXCLUSIVE -> failwith "System Exclusive messages not supported"
      | TIME_CODE -> failwith "Time Code messages not supported"
      | SONG_POSITION -> failwith "Song Position messages not supported"
      | SONG_SELECT -> failwith "Song Select messages not supported"
      | TUNE_REQUEST -> failwith "Tune Request messages not supported"
      | END_OF_EXCLUSIVE -> failwith "End of Exclusive messages not supported"
      | TIMING_CLOCK -> failwith "Timing Clock messages not supported"
      | START -> failwith "Start messages not supported"
      | CONTINUE -> failwith "Continue messages not supported"
      | STOP -> failwith "Stop messages not supported"
      | ACTIVE_SENSING -> failwith "Active Sensing messages not supported"
      | SYSTEM_RESET -> failwith "System Reset messages not supported"
    in
    previous_status := Some (Bytes.get bytes 0);
    bytes

  let deserialize (bytes : Bytes.t) : t =
    let length = Bytes.length bytes in
    if length < 2 || length > 3 then failwith "Invalid MIDI message bytes";
    let status_byte =
      match !previous_status with
      | Some byte -> byte
      | None -> Bytes.get bytes 0
    in
    let message_type, data1, data2 =
      if length = 2 then
        match !previous_status with
        | Some byte ->
            let message_type =
              match int_of_char byte land 0xF0 with
              | 0x80 -> NOTE_OFF
              | 0x90 -> NOTE_ON
              | 0xA0 -> POLY_PRESSURE
              | 0xB0 -> CONTROL_CHANGE
              | 0xC0 -> PROGRAM_CHANGE
              | 0xD0 -> CHANNEL_PRESSURE
              | 0xE0 -> PITCH_BEND
              | _ -> failwith "Invalid MIDI message status byte"
            in
            let channel = int_of_char byte land 0x0F in
            let data1 = Bytes.get bytes 0 in
            let data2 = Bytes.get bytes 1 in
            (message_type, data1, data2)
        | None -> failwith "Invalid MIDI message bytes"
      else
        let message_type =
          match int_of_char status_byte land 0xF0 with
          | 0x80 -> NOTE_OFF
          | 0x90 -> NOTE_ON
          | 0xA0 -> POLY_PRESSURE
          | 0xB0 -> CONTROL_CHANGE
          | 0xC0 -> PROGRAM_CHANGE
          | 0xD0 -> CHANNEL_PRESSURE
          | 0xE0 -> PITCH_BEND
          | _ -> failwith "Invalid MIDI message status byte"
        in
        let channel = int_of_char status_byte land 0x0F in
        let data1 = Bytes.get bytes 1 in
        let data2 =
          if message_type = PROGRAM_CHANGE || message_type = CHANNEL_PRESSURE
          then 0
          else Bytes.get bytes 2
        in
        (message_type, data1, data2)
    in
    let timestamp = 0 in
    (* Set timestamp to 0 for now *)
    let message =
      create ~message_type ~channel ~data1:(int_of_char data1)
        ~data2:(int_of_char data2) ~timestamp
    in
    previous_status := Some status_byte;
    message
end
