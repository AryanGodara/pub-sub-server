module type TOPIC_FILTER = sig
  val addSocket : string -> Unix.file_descr -> unit
  val removeSocket : string -> Unix.file_descr -> unit
  val getSockets : string -> Unix.file_descr list
end

module TOPICFILTER : TOPIC_FILTER = struct
  module UnixSocketMap = Map.Make (String)

  let socketMap = ref UnixSocketMap.empty

  let addSocket topic socket =
    let sockets =
      try UnixSocketMap.find topic !socketMap with Not_found -> []
    in
    socketMap :=
      UnixSocketMap.add topic (List.append sockets [ socket ]) !socketMap

  let removeSocket topic socket =
    let sockets =
      try UnixSocketMap.find topic !socketMap with Not_found -> []
    in
    let sockets' = List.filter (fun s -> s <> socket) sockets in
    socketMap := UnixSocketMap.add topic sockets' !socketMap

  let getSockets topic =
    let sockets =
      try UnixSocketMap.find topic !socketMap with Not_found -> []
    in
    List.rev sockets
end
