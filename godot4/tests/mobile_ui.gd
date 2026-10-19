extends SceneTree

const UI = preload("res://client_ui.gd")
var failures := 0

class FakeLink extends RefCounted:
	var messages: Array = []
	func send(message: Dictionary) -> Error:
		messages.append(message)
		return OK
	func close() -> void:
		pass

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _run() -> void:
	check(UI.safe_area_insets(Rect2(0, 177, 1170, 2253), Vector2(1170, 2532), Vector2(390, 844)).is_equal_approx(Vector4(0, 59, 0, 34)), "portrait safe area converts physical pixels to logical coordinates")
	check(UI.safe_area_insets(Rect2(177, 0, 2178, 1107), Vector2(2532, 1170), Vector2(844, 390)).is_equal_approx(Vector4(59, 0, 59, 21)), "landscape safe area protects both sides and home indicator")
	check(UI.safe_area_insets(Rect2(), Vector2.ZERO, Vector2.ONE) == Vector4.ZERO, "unavailable safe area has zero insets")
	var ui := UI.new()
	root.add_child(ui)
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.content_scale_size = Vector2i(390, 390)
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	for viewport_size in [Vector2i(390, 844), Vector2i(844, 390)]:
		root.size = viewport_size
		for _frame in range(5):
			await process_frame
		check(ui.host.get_global_rect().end.x <= ui.size.x, "host field fits %s" % viewport_size)
		check(ui.connect_button.get_global_rect().end.x <= ui.size.x, "connect button fits %s" % viewport_size)
		check(ui.screen.size.y > 0 and ui.screen.get_global_rect().end.y <= ui.size.y, "stream area fits %s" % viewport_size)
	var fake := FakeLink.new()
	ui.client.set_process(false)
	ui.client.link = fake
	ui.client.authenticated = true
	var image := Image.create(64, 32, false, Image.FORMAT_RGB8)
	ui._frame_received(image)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	touch.position = ui._image_rect().get_center()
	ui._input(touch)
	check(fake.messages.size() == 1 and fake.messages[0].event.type == "touch", "touch forwarded once")
	var emulated := InputEventMouseButton.new()
	emulated.device = InputEvent.DEVICE_ID_EMULATION
	emulated.button_index = MOUSE_BUTTON_LEFT
	emulated.pressed = true
	emulated.position = touch.position
	ui._input(emulated)
	check(fake.messages.size() == 1, "emulated mouse is not duplicated onto remote game")
	check(ProjectSettings.get_setting("input_devices/pointing/emulate_mouse_from_touch"), "touch mouse emulation remains enabled for local GUI controls")
	ui._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(not ui.client.authenticated and ui.client.link == null, "backgrounding disconnects and releases remote connection")
	ui.queue_free()
	await process_frame
	print("Mobile UI failures: %d" % failures)
	quit(0 if failures == 0 else 1)
