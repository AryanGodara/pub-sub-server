# pub-sub-server

## These are the different types of messages that can be sent to the server

1. NoteOff: A message that turns off a note that was previously turned on. For example, sending a NoteOff message with a note value of 60 (middle C) and a velocity of 0 would turn off the middle C note.

2. NoteOn: A message that turns on a note. For example, sending a NoteOn message with a note value of 64 (E4) and a velocity of 127 would turn on the E4 note with maximum velocity.

3. PolyphonicKeyPressure: A message that applies pressure to a specific note. For example, sending a PolyphonicKeyPressure message with a note value of 72 (C5) and a pressure value of 64 would apply pressure to the C5 note.

4. ControlChange: A message that changes a control value. For example, sending a ControlChange message with a controller value of 7 (volume) and a value of 100 would set the volume to 100.

5. ProgramChange: A message that changes the program (instrument) on a specific channel. For example, sending a ProgramChange message with a program value of 1 (piano) on channel 1 would change the instrument to piano on channel 1.

6. ChannelPressure: A message that applies pressure to all notes on a specific channel. For example, sending a ChannelPressure message with a pressure value of 64 on channel 1 would apply pressure to all notes on channel 1.

7. PitchBend: A message that changes the pitch bend value. For example, sending a PitchBend message with a value of 8192 (center position) on channel 1 would set the pitch bend to the center position on channel 1.

8. SystemExclusive: A message that sends a system exclusive message. This message type is used for manufacturer-specific messages and is not standardized. An example of a system exclusive message would be a message that sets a specific parameter on a synthesizer.

9. TimeCode: A message that sends a time code value. For example, sending a TimeCode message with a value of 30 would set the time code to 30.

10. SongPosition: A message that sets the song position pointer value. For example, sending a SongPosition message with a value of 1000 would set the song position pointer to 1000.

11. SongSelect: A message that selects a specific song. For example, sending a SongSelect message with a song value of 5 would select song 5.

12. TuneRequest: A message that requests a tuning message from a device. For example, sending a TuneRequest message would request a tuning message from a synthesizer.

13. EndOfExclusive: A message that marks the end of a system exclusive message. For example, sending an EndOfExclusive message would mark the end of a system exclusive message.

14. TimingClock: A message that sends a timing clock message. For example, sending a TimingClock message would send a timing clock message to a device.

15. Start: A message that starts playback. For example, sending a Start message would start playback on a sequencer.

16. Continue: A message that continues playback. For example, sending a Continue message would continue playback on a sequencer.

17. Stop: A message that stops playback. For example, sending a Stop message would stop playback on a sequencer.

18. ActiveSensing: A message that sends an active sensing message. This message type is used to ensure that the connection between devices is still active. For example, sending an 
ActiveSensing message would send an active sensing message to a device.

19. SystemReset: A message that sends a system reset message. For example, sending a SystemReset message would send a system reset message to a device.

## And here are the examples for each of these messages

1. NoteOff: 0x80 0x3C 0x40 - turns off the middle C note on channel 1 with a velocity of 64.

2. NoteOn: 0x90 0x40 0x7F - turns on the E4 note on channel 1 with a velocity of 127.

3. PolyphonicKeyPressure: 0xA0 0x48 0x40 - applies pressure to the C5 note on channel 1 with a pressure value of 64.

4. ControlChange: 0xB0 0x07 0x64 - sets the volume to 100 on channel 1.

5. ProgramChange: 0xC1 0x01 - changes the instrument to piano on channel 2.

6. ChannelPressure: 0xD0 0x40 - applies pressure to all notes on channel 1 with a pressure value of 64.

7. PitchBend: 0xE0 0x00 0x40 - sets the pitch bend to the center position on channel 1.

8. SystemExclusive: 0xF0 0x7E 0x7F 0x06 0x01 0xF7 - sends a system exclusive message with the data bytes 0x7E 0x7F 0x06 0x01.

9. TimeCode: 0xF1 0x1E - sets the time code to 30.

10. SongPosition: 0xF2 0x20 0x0C - sets the song position pointer to 1000.

11. SongSelect: 0xF3 0x05 - selects song 5.

12. TuneRequest: 0xF6 - requests a tuning message from a synthesizer.

13. EndOfExclusive: 0xF7 - marks the end of a system exclusive message.

14. TimingClock: 0xF8 - sends a timing clock message to a device.

15. Start: 0xFA - starts playback on a sequencer.

16. Continue: 0xFB - continues playback on a sequencer.

17. Stop: 0xFC - stops playback on a sequencer.

18. ActiveSensing: 0xFE - sends an active sensing message to a device.

19. SystemReset: 0xFF - sends a system reset message to a device.


## The device module in midi.ml

The Device module in the midi.ml module provides an interface for creating and managing MIDI output devices. It defines a Device type that represents a MIDI output device, along with functions for creating and shutting down devices.

The create function takes an integer device ID as an argument and returns a Device value that represents the MIDI output device with the given ID. The shutdown function takes a Device value as an argument and shuts down the MIDI output device.

The Device module is useful for managing MIDI output devices in a program that sends MIDI messages. It allows you to create and shut down devices as needed, and provides a convenient way to send MIDI messages to specific devices.