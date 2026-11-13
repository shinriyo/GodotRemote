extends SceneTree

const Server = preload("res://addons/godot_remote/server.gd")
const Client = preload("res://addons/godot_remote/client.gd")
const Codec = preload("res://addons/godot_remote/input_codec.gd")
var server := Server.new()
var client := Client.new()
var failures := 0
var received_image: Image
var received_event: InputEvent
var received_data: Variant
var received_sensors := {}

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, label: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: " + label)

func wait_for(predicate: Callable) -> bool:
	var deadline := Time.get_ticks_msec() + 3000
	while not predicate.call() and Time.get_ticks_msec() < deadline:
		await process_frame
	return predicate.call()

func _run() -> void:
	root.add_child(server)
	root.add_child(client)
	server.capture_enabled = false
	server.password = "test-password"
	var port := 24766
	var listen_error := server.start(port, "127.0.0.1")
	check(listen_error == OK, "server listens on loopback")
	if listen_error != OK:
		quit(1)
		return
	client.frame_received.connect(func(image): received_image = image)
	server.remote_input.connect(func(event): received_event = event)
	server.user_data_received.connect(func(id, data): received_data = [id, data])
	check(client.connect_to_host("127.0.0.1", port, "wrong") == OK, "connect with wrong password")
	check(await wait_for(func(): return client.link == null), "wrong password rejected")
	check(not server.authenticated, "rejected client has no access")
	client.connect_to_host("127.0.0.1", port, server.password)
	check(await wait_for(func(): return client.authenticated), "authenticated handshake")
	var image := Image.create(64, 32, false, Image.FORMAT_RGB8)
	image.fill(Color(0.2, 0.6, 0.9))
	check(server.send_frame(image) == OK, "send JPEG frame")
	check(server.send_frame(image) == ERR_UNAVAILABLE, "backpressure blocks unacknowledged frame")
	check(await wait_for(func(): return received_image != null), "client decodes frame")
	if received_image:
		check(received_image.get_size() == Vector2i(32, 16), "frame scaling")
		check(received_image.get_pixel(0, 0).is_equal_approx(Color(0.2, 0.6, 0.9)) or absf(received_image.get_pixel(0, 0).b - 0.9) < 0.05, "JPEG pixel content")
	check(await wait_for(func(): return not server._frame_pending), "frame acknowledgement")
	var touch := InputEventScreenTouch.new()
	touch.index = 2
	touch.pressed = true
	touch.position = Vector2(150, 100)
	client.send_input(touch, Rect2(50, 50, 200, 100))
	check(await wait_for(func(): return received_event != null), "touch transmitted")
	if received_event:
		check(received_event.index == 2 and received_event.pressed, "touch properties preserved")
		check(received_event.position.is_equal_approx(root.get_visible_rect().size * 0.5), "letterbox coordinates mapped to server viewport")
	check(Codec.decode({"type": "touch", "index": 0, "pressed": true, "position": "bad"}, Vector2.ONE) == null, "malformed input rejected")
	check(Codec.decode({"type": "key", "pressed": true}, Vector2.ONE) == null, "incomplete key rejected")
	client.send_user_data("example", {"value": 42})
	check(await wait_for(func(): return received_data != null), "custom data transmitted")
	check(received_data == ["example", {"value": 42}], "custom data intact")
	server.sensors_received.connect(func(values): received_sensors = values)
	var sensors := {"accelerometer": Vector3(1, 2, 3), "gravity": Vector3(0, 9.8, 0), "gyroscope": Vector3(4, 5, 6), "magnetometer": Vector3(7, 8, 9)}
	client.link.send({"type": "sensors", "values": sensors})
	check(await wait_for(func(): return not received_sensors.is_empty()), "sensor data transmitted")
	check(Input.get_accelerometer() == sensors.accelerometer and Input.get_gyroscope() == sensors.gyroscope, "sensor values applied to Input")
	var key := InputEventKey.new()
	key.keycode = KEY_A
	key.physical_keycode = KEY_A
	key.shift_pressed = true
	key.pressed = true
	var decoded := Codec.decode(Codec.encode(key, Rect2()), Vector2.ONE) as InputEventKey
	check(decoded != null and decoded.keycode == KEY_A and decoded.shift_pressed and decoded.pressed, "keyboard and modifiers round trip")
	var drag := InputEventScreenDrag.new()
	drag.index = 2
	drag.position = Vector2(150, 100)
	drag.relative = Vector2(10, 5)
	var decoded_drag := Codec.decode(Codec.encode(drag, Rect2(50, 50, 200, 100)), Vector2(400, 200)) as InputEventScreenDrag
	check(decoded_drag != null and decoded_drag.relative == Vector2(20, 10), "drag relative coordinates scale")
	check(not server._held.is_empty(), "pressed input tracked")
	client.disconnect_from_host()
	check(await wait_for(func(): return not server.authenticated), "disconnect detected")
	check(server._held.is_empty(), "held input released on disconnect")
	check(Input.get_accelerometer() == Vector3.ZERO, "sensor state reset on disconnect")
	client.connect_to_host("127.0.0.1", port, server.password)
	check(await wait_for(func(): return client.authenticated), "reconnect succeeds")
	client.disconnect_from_host()
	server.stop()
	server.queue_free()
	client.queue_free()
	await process_frame
	print("Integration failures: %d" % failures)
	quit(0 if failures == 0 else 1)
