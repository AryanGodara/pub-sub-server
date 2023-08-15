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

module MIDI_MESSAGE = struct
  type t = {
    message_type : midi_type;
    status_byte : int;
    channel : int;
    data1 : int;
    data2 : int;
    timestamp : int;
  }

  let create ~message_type ~channel ~data1 ~data2 ~timestamp =
    let status_byte =
      match message_type with
      | NOTE_OFF -> 0x80
      | NOTE_ON -> 0x90
      | POLY_PRESSURE -> 0xA0
      | CONTROL_CHANGE -> 0xB0
      | PROGRAM_CHANGE -> 0xC0
      | CHANNEL_PRESSURE -> 0xD0
      | PITCH_BEND -> 0xE0
      | SYSTEM_EXCLUSIVE -> 0xF0
      | TIME_CODE -> 0xF1
      | SONG_POSITION -> 0xF2
      | SONG_SELECT -> 0xF3
      | TUNE_REQUEST -> 0xF6
      | END_OF_EXCLUSIVE -> 0xF7
      | TIMING_CLOCK -> 0xF8
      | START -> 0xFA
      | CONTINUE -> 0xFB
      | STOP -> 0xFC
      | ACTIVE_SENSING -> 0xFE
      | SYSTEM_RESET -> 0xFF
    in
    { message_type; status_byte; channel; data1; data2; timestamp }
end

module UDP_SERIALIZER = struct
  let previous_status = ref None

  let serialize (message : MIDI_MESSAGE.t) : Bytes.t =
    let status_byte =
      Char.chr
        (message.MIDI_MESSAGE.status_byte lor message.MIDI_MESSAGE.channel)
    in
    let data1_byte = Char.chr message.MIDI_MESSAGE.data1 in
    let data2_byte = Char.chr message.MIDI_MESSAGE.data2 in
    let bytes =
      match message.MIDI_MESSAGE.message_type with
      | NOTE_OFF ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" (Char.chr 0x80) data1_byte data2_byte)
      | NOTE_ON ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c" status_byte data1_byte data2_byte)
      | POLY_PRESSURE ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xA0 lor message.MIDI_MESSAGE.channel))
               data1_byte data2_byte)
      | CONTROL_CHANGE ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xB0 lor message.MIDI_MESSAGE.channel))
               data1_byte data2_byte)
      | PROGRAM_CHANGE ->
          Bytes.of_string
            (Printf.sprintf "%c%c"
               (char_of_int (0xC0 lor message.MIDI_MESSAGE.channel))
               data1_byte)
      | CHANNEL_PRESSURE ->
          Bytes.of_string
            (Printf.sprintf "%c%c"
               (char_of_int (0xD0 lor message.MIDI_MESSAGE.channel))
               data1_byte)
      | PITCH_BEND ->
          Bytes.of_string
            (Printf.sprintf "%c%c%c"
               (char_of_int (0xE0 lor message.MIDI_MESSAGE.channel))
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
    bytes

  let deserialize bytes =
    let length = Bytes.length bytes in
    if length <> 3 then failwith "Invalid MIDI message bytes";
    let status_byte =
      match !previous_status with
      | Some byte -> byte
      | None -> Bytes.get bytes 0
    in
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
    let data2 = Bytes.get bytes 2 in
    let timestamp = 0 in
    (* Set timestamp to 0 for now *)
    let message =
      MIDI_MESSAGE.create ~message_type ~channel ~data1:(int_of_char data1)
        ~data2:(int_of_char data2) ~timestamp
    in
    previous_status := Some status_byte;
    message
end

let midi_to_bytes (message : MIDI_MESSAGE.t) : Bytes.t =
  UDP_SERIALIZER.serialize message

let bytes_to_midi (bytes : Bytes.t) : MIDI_MESSAGE.t =
  UDP_SERIALIZER.deserialize bytes
