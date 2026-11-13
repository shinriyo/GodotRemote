extends Node

signal connected
signal disconnected(reason: String)
signal frame_received(image: Image)
signal user_data_received(id: String, data: Variant)

const Link = preload("link.gd")
const Codec = preload("input_codec.gd")
var authenticated := false
var send_sensors := OS.has_feature("mobile")
var _sensor_time := 0.0
var link: RefCounted
var _password := ""
var _hello_sent := false
var _ping_time := 0.0
var _last_received := 0

func connect_to_host(host: String, port: int = 22766, password: String = "") -> Error:
	disconnect_from_host()
	var tcp := StreamPeerTCP.new()
	var error := tcp.connect_to_host(host, port)
	if error != OK:
		return error
	link = Link.new(tcp)
	_password = password
	_last_received = Time.get_ticks_msec()
	return OK

func disconnect_from_host(reason: String = "Disconnected") -> void:
	var had_link := link != null
	if link:
		link.close()
	link = null
	authenticated = false
	_hello_sent = false
	_ping_time = 0.0
	if had_link:
		disconnected.emit(reason)

func _exit_tree() -> void:
	disconnect_from_host()

func _process(delta: float) -> void:
	if not link:
		return
	var status: int = link.poll()
	if status in [StreamPeerTCP.STATUS_NONE, StreamPeerTCP.STATUS_ERROR] or Time.get_ticks_msec() - _last_received > 10000:
		disconnect_from_host("Connection closed or timed out; check address, port and password")
		return
	if status != StreamPeerTCP.STATUS_CONNECTED:
		return
	if not _hello_sent:
		link.send({"type": "hello", "version": Link.VERSION, "password": _password})
		_hello_sent = true
	for message in link.receive():
		_last_received = Time.get_ticks_msec()
		match message.get("type"):
			"ready":
				if message.get("version") != Link.VERSION:
					disconnect_from_host("Protocol version mismatch")
					return
				authenticated = true
				connected.emit()
			"frame":
				if authenticated and message.get("jpeg") is PackedByteArray:
					var image := Image.new()
					if image.load_jpg_from_buffer(message.jpeg) == OK:
						frame_received.emit(image)
					link.send({"type": "ack"})
			"user":
				if authenticated and message.get("id") is String:
					user_data_received.emit(message.id, message.get("data"))
	_sensor_time += delta
	if authenticated and send_sensors and _sensor_time >= 1.0 / 30.0:
		_sensor_time = 0.0
		link.send({"type": "sensors", "values": {
			"accelerometer": Input.get_accelerometer(), "gravity": Input.get_gravity(),
			"gyroscope": Input.get_gyroscope(), "magnetometer": Input.get_magnetometer()}})
	_ping_time += delta
	if authenticated and _ping_time >= 2.0:
		_ping_time = 0.0
		link.send({"type": "ping"})

func send_input(event: InputEvent, display_rect: Rect2) -> Error:
	if not authenticated:
		return ERR_UNAVAILABLE
	var data := Codec.encode(event, display_rect)
	if data.is_empty():
		return ERR_INVALID_PARAMETER
	return link.send({"type": "input", "event": data})

func send_user_data(id: String, data: Variant) -> Error:
	if not authenticated:
		return ERR_UNAVAILABLE
	return link.send({"type": "user", "id": id, "data": data})
