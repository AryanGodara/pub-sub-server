module MIDI_MESSAGE = struct
  type t = {
    status : int;
    channel : int;
    data1 : int;
    data2 : int;
    timestamp : int;
  }

  type b = STATUS_BYTE of Bytes.t | DATA_BYTE of Bytes.t

  let last_status_byte = ref None

  let create ~status ~channel ~data1 ~data2 ~timestamp =
    last_status_byte := Some status;
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
    let length = Bytes.length bytes in
    if length <> 3 && length <> 4 then failwith "Invalid MIDI message bytes";
    let status_byte =
      if length = 4 then Bytes.get bytes 0
      else
        match !MIDI_MESSAGE.last_status_byte with
        | Some byte -> char_of_int byte
        | None -> failwith "Invalid MIDI message bytes"
    in
    let status = int_of_char status_byte land 0xF0 in
    let channel = int_of_char status_byte land 0x0F in
    let data1 = Bytes.get bytes (length - 2) in
    let data2 = Bytes.get bytes (length - 1) in
    let timestamp = 0 in
    (* Set timestamp to 0 for now *)
    let message =
      MIDI_MESSAGE.create ~status ~channel ~data1:(int_of_char data1)
        ~data2:(int_of_char data2) ~timestamp
    in
    if length = 4 then
      MIDI_MESSAGE.last_status_byte := Some (int_of_char status_byte);
    message
end

let midi_to_bytes (message : MIDI_MESSAGE.t) : Bytes.t =
  UDP_SERIALIZER.serialize message

let bytes_to_midi (bytes : Bytes.t) : MIDI_MESSAGE.t =
  UDP_SERIALIZER.deserialize bytes
