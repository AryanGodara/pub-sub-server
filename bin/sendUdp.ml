module Rtpmidi_sender = struct
  let send_midi_message ~midi_message ~destination_ip ~destination_port =
    let socket = Udp.create () in
    let bytes = midi_to_bytes midi_message in
    let packet = Rtp.create_packet ~payload:bytes in
    let packet_bytes = Rtp.serialize_packet packet in
    Udp.sendto socket packet_bytes 0
      (Bytes.length packet_bytes)
      destination_ip destination_port;
    Udp.close socket
end
