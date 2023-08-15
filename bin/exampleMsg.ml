open Rtpmidi

(* Example UDP message bytes *)
let udp_message_bytes = Bytes.of_string "\x90\x3C\x7F"

(* Deserialize the UDP message into a MIDI message *)
let midi_message = bytes_to_midi udp_message_bytes

(* Extract the MIDI message fields *)
let message_type = midi_message.MIDI_MESSAGE.message_type (* NOTE_ON *)
let channel = midi_message.MIDI_MESSAGE.channel (* 0 *)
let note_number = midi_message.MIDI_MESSAGE.data1 (* 60 *)
let velocity = midi_message.MIDI_MESSAGE.data2 (* 127 *)



(* Suppose we want to send two Note On messages, one for note number 60 with a velocity of 100, and another for note number 62 with a velocity of 80. 
Normally, we would send these messages as follows:

```
90 3C 64   ; Note On, channel 1, note number 60, velocity 100
90 3E 50   ; Note On, channel 1, note number 62, velocity 80
```

However, with Running Status, we can omit the status byte for the second message, since it is the same as the previous message. 
This reduces the amount of data sent over the MIDI connection:

```
90 3C 64   ; Note On, channel 1, note number 60, velocity 100
3E 50      ; Note On, channel 1, note number 62, velocity 80 (Running Status)
```

In this example, the first message is a standard Note On message with a status byte of 0x90. 
The second message omits the status byte, since it is the same as the previous message. Instead, it only includes the data bytes for the note number and velocity. 
The receiver can infer that this is a Note On message with a status byte of 0x90, since that was the status byte of the previous message. *)