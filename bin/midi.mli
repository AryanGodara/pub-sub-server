module Event = Portmidi.Portmidi_event

(** MIDI message types *)
type message_type =
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

(** MIDI message *)
type message = {
  message_type : message_type;
  channel : int;
  data1 : char;
  data2 : char;
  timestamp : int32;
}

(** MIDI device *)
module Device : sig
  type t = { device_id : int; device : Portmidi.Output_stream.t }

  (** Create a MIDI device with the given device ID *)
  val create : int -> t

  (** Shutdown the MIDI device *)
  val shutdown : t -> unit
end

(** Initialize the MIDI system *)
val init : unit -> unit

(** Convert a Portmidi error to a string *)
val error_to_string : Portmidi.Portmidi_error.t -> string

(** MIDI message constructors *)
val message_on : note:char -> timestamp:int32 -> volume:char -> channel:int -> unit -> Event.t
val message_off : note:char -> timestamp:int32 -> volume:char -> channel:int -> unit -> Event.t
val message_poly_pressure : note:char -> pressure:char -> timestamp:int32 -> channel:int -> unit -> Event.t
val message_control_change : controller:char -> value:char -> timestamp:int32 -> channel:int -> unit -> Event.t
val message_program_change : program:char -> timestamp:int32 -> channel:int -> unit -> Event.t
val message_channel_pressure : pressure:char -> timestamp:int32 -> channel:int -> unit -> Event.t
val message_pitch_bend : value:int -> timestamp:int32 -> channel:int -> unit -> Event.t
val message_system_exclusive : data:int -> timestamp:int32 -> unit -> Event.t
val message_time_code : value:char -> timestamp:int32 -> unit -> Event.t
val message_song_position : position:int -> timestamp:int32 -> unit -> Event.t
val message_song_select : song:char -> timestamp:int32 -> unit -> Event.t
val message_tune_request : timestamp:int32 -> unit -> Event.t
val message_end_of_exclusive : timestamp:int32 -> unit -> Event.t
val message_timing_clock : timestamp:int32 -> unit -> Event.t
val message_start : timestamp:int32 -> unit -> Event.t
val message_continue : timestamp:int32 -> unit -> Event.t
val message_stop : timestamp:int32 -> unit -> Event.t
val message_active_sensing : timestamp:int32 -> unit -> Event.t
val message_system_reset : timestamp:int32 -> unit -> Event.t

(** Handle a Portmidi result, printing an error message if necessary *)
val handle_error : ('a, Portmidi.Portmidi_error.t) result -> unit

(** Write a list of MIDI events to a MIDI device *)
val write_output : Device.t -> Event.t list -> unit