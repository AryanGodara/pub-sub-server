module Rtpmidi_receiver = struct
  let receive_midi_message ~local_port =
    let socket = Udp.create () in
    Udp.bind socket (Unix.ADDR_INET (Unix.inet_addr_any, local_port));
    let buffer = Bytes.create 2048 in
    let rec loop () =
      let length, sender = Udp.recvfrom socket buffer 0 (Bytes.length buffer) in
      let packet_bytes = Bytes.sub buffer 0 length in
      let packet = Rtp.deserialize_packet packet_bytes in
      match packet with
      | None -> loop ()
      | Some packet ->
        let bytes = Rtp.get_payload packet in
        let midi_message = bytes_to_midi bytes in
        Udp.close socket;
        midi_message
    in
    let midi_message = loop () in
    midi_message
end