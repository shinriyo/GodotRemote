extends RefCounted

const VERSION := 1
const MAX_PACKET := 8 * 1024 * 1024
var tcp: StreamPeerTCP
var packets := PacketPeerStream.new()

func _init(stream: StreamPeerTCP) -> void:
	tcp = stream
	packets.input_buffer_max_size = MAX_PACKET
	packets.output_buffer_max_size = MAX_PACKET
	packets.stream_peer = tcp
	tcp.set_no_delay(true)

func poll() -> int:
	tcp.poll()
	return tcp.get_status()

func send(message: Dictionary) -> Error:
	return packets.put_var(message, false)

func receive() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for _i in range(mini(packets.get_available_packet_count(), 64)):
		var value: Variant = packets.get_var(false)
		if packets.get_packet_error() != OK or not value is Dictionary:
			close()
			break
		result.append(value)
	return result

func close() -> void:
	tcp.disconnect_from_host()
