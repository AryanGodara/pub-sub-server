module Event = Portmidi.Portmidi_event

val init : unit -> unit
val error_to_string : Portmidi.Portmidi_error.t -> string

val message_on :
  note:char -> timestamp:int32 -> volume:char -> channel:int -> unit -> Event.t

val message_off :
  note:char -> timestamp:int32 -> volume:char -> channel:int -> unit -> Event.t

module Device : sig
  type t

  val create : int -> t
  val shutdown : t -> (unit, Portmidi.Portmidi_error.t) result
end

type note_data = { note : char; volume : char }

val write_output : Device.t -> Portmidi.Portmidi_event.t list -> unit
val handle_error : ('a, Portmidi.Portmidi_error.t) result -> unit
