extends Node

signal client_connected
signal client_disconnected
signal remote_input(event: InputEvent)
signal sensors_received(values: Dictionary)
signal user_data_received(id: String, data: Variant)

const Link = preload("link.gd")
const Codec = preload("input_codec.gd")
var password := ""
var fps := 20
var quality := 0.65
var image_scale := 0.5
var capture_enabled := true
var authenticated := false
var listener := TCPServer.new()
var link: RefCounted
var _elapsed := 0.0
var _last_received := 0
var _frame_pending := false
var _capturing := false
var _held := {}

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start(port: int = 22766, bind_address: String = "*") -> Error:
	stop()
	return listener.listen(port, bind_address)

func stop() -> void:
	_drop()
	listener.stop()

func _exit_tree() -> void:
	stop()

func _drop() -> void:
	var was_connected := authenticated
	authenticated = false
	_frame_pending = false
	if link:
		link.close()
		link = null
	for event in _held.values():
		event.pressed = false
		Input.parse_input_event(event)
	_held.clear()
	if was_connected:
		Input.set_accelerometer(Vector3.ZERO)
		Input.set_gravity(Vector3.ZERO)
		Input.set_gyroscope(Vector3.ZERO)
		Input.set_magnetometer(Vector3.ZERO)
	if was_connected:
		client_disconnected.emit()

func _process(delta: float) -> void:
	if listener.is_connection_available():
		var stream := listener.take_connection()
		if link:
			stream.disconnect_from_host()
		else:
			link = Link.new(stream)
			_last_received = Time.get_ticks_msec()
	if not link:
		return
	if link.poll() != StreamPeerTCP.STATUS_CONNECTED or Time.get_ticks_msec() - _last_received > (10000 if authenticated else 3000):
		_drop()
		return
	for message in link.receive():
		_handle(message)
		if not link:
			return
	_elapsed += delta
	if authenticated and capture_enabled and not _frame_pending and not _capturing and _elapsed >= 1.0 / clampi(fps, 1, 60):
		_elapsed = 0.0
		_capture()

func _handle(message: Dictionary) -> void:
	_last_received = Time.get_ticks_msec()
	if not authenticated:
		if message.get("type") != "hello" or message.get("version") != Link.VERSION or message.get("password") != password:
			_drop()
			return
		authenticated = true
		link.send({"type": "ready", "version": Link.VERSION})
		client_connected.emit()
		return
	match message.get("type"):
		"ack":
			_frame_pending = false
		"ping":
			link.send({"type": "pong"})
		"input":
			if not message.get("event") is Dictionary:
				return
			var event := Codec.decode(message.event, get_viewport().get_visible_rect().size)
			if event:
				_track(event)
				remote_input.emit(event)
				Input.parse_input_event(event)
		"sensors":
			var values: Variant = message.get("values")
			if not values is Dictionary:
				return
			for key in ["accelerometer", "gravity", "gyroscope", "magnetometer"]:
				if not values.get(key) is Vector3 or not values[key].is_finite():
					return
			Input.set_accelerometer(values.accelerometer)
			Input.set_gravity(values.gravity)
			Input.set_gyroscope(values.gyroscope)
			Input.set_magnetometer(values.magnetometer)
			sensors_received.emit(values)
		"user":
			if message.get("id") is String:
				user_data_received.emit(message.id, message.get("data"))

func _track(event: InputEvent) -> void:
	var key := ""
	if event is InputEventScreenTouch:
		key = "touch:%s" % event.index
	elif event is InputEventMouseButton:
		key = "button:%s" % event.button_index
	elif event is InputEventKey:
		key = "key:%s:%s" % [event.keycode, event.physical_keycode]
	if not key.is_empty():
		if event.pressed:
			_held[key] = event.duplicate()
		else:
			_held.erase(key)

func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		return
	_capturing = true
	await RenderingServer.frame_post_draw
	if is_inside_tree() and authenticated:
		send_frame(get_viewport().get_texture().get_image())
	_capturing = false

func send_frame(image: Image) -> Error:
	if not authenticated or _frame_pending or image == null or image.is_empty():
		return ERR_UNAVAILABLE
	var copy := image.duplicate() as Image
	var factor := clampf(image_scale, 0.1, 1.0)
	copy.resize(maxi(1, int(copy.get_width() * factor)), maxi(1, int(copy.get_height() * factor)))
	var jpeg := copy.save_jpg_to_buffer(clampf(quality, 0.1, 1.0))
	if jpeg.size() > Link.MAX_PACKET - 1024:
		return ERR_OUT_OF_MEMORY
	var error: Error = link.send({"type": "frame", "jpeg": jpeg})
	_frame_pending = error == OK
	return error

func send_user_data(id: String, data: Variant) -> Error:
	if not authenticated:
		return ERR_UNAVAILABLE
	return link.send({"type": "user", "id": id, "data": data})
