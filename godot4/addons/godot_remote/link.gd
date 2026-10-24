extends RefCounted

const VERSION := 1
const MAX_PACKET := 8 * 1024 * 1024
var tcp: StreamPeerTCP
var websocket: WebSocketPeer
var is_websocket := false
var packets := PacketPeerStream.new()

func _init(stream: Variant, websocket_mode := false) -> void:
	is_websocket = websocket_mode
	if is_websocket:
		if stream is WebSocketPeer:
			websocket = stream
		else:
			websocket = WebSocketPeer.new()
			websocket.accept_stream(stream)
		return
	tcp = stream
	packets.input_buffer_max_size = MAX_PACKET
	packets.output_buffer_max_size = MAX_PACKET
	packets.stream_peer = tcp
	tcp.set_no_delay(true)

func poll() -> int:
	if is_websocket:
		websocket.poll()
		return websocket.get_ready_state()
	tcp.poll()
	return tcp.get_status()

func send(message: Dictionary) -> Error:
	if is_websocket:
		return websocket.send(var_to_bytes(message), WebSocketPeer.WRITE_MODE_BINARY)
	return packets.put_var(message, false)

func receive() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if is_websocket:
		while websocket.get_available_packet_count() > 0:
			var value: Variant = bytes_to_var(websocket.get_packet())
			if not value is Dictionary:
				close()
				break
			result.append(value)
		return result
	for _i in range(mini(packets.get_available_packet_count(), 64)):
		var value: Variant = packets.get_var(false)
		if packets.get_packet_error() != OK or not value is Dictionary:
			close()
			break
		result.append(value)
	return result

func close() -> void:
	if is_websocket:
		websocket.close()
		return
	tcp.disconnect_from_host()
