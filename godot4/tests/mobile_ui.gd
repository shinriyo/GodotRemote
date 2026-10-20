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
	ui._servers_changed([{ "id": "long", "name": "Remote iPhone Check with a very long game name", "host": "192.168.0.241", "port": 22766 }])
	ui.server_picker.select(1)
	for viewport_size in [Vector2i(390, 844), Vector2i(844, 390)]:
		root.size = viewport_size
		for _frame in range(5):
			await process_frame
		ui._refresh_server_labels()
		var label_width := ui.server_picker.get_theme_font("font").get_string_size(ui.server_picker.get_item_text(1), HORIZONTAL_ALIGNMENT_LEFT, -1, ui.server_picker.get_theme_font_size("font_size")).x
		check(label_width <= root.get_visible_rect().size.x - 100, "popup label fits %s" % viewport_size)
		check(ui._safe_margin.size.x <= ui.size.x, "long server selection does not widen layout %s" % viewport_size)
		check(ui.host.get_global_rect().end.x <= ui.size.x, "host field fits %s" % viewport_size)
		check(ui.connect_button.get_global_rect().end.x <= ui.size.x, "connect button fits %s" % viewport_size)
		check(ui.screen.size.y > 0 and ui.screen.get_global_rect().end.y <= ui.size.y, "stream area fits %s" % viewport_size)
	var fake := FakeLink.new()
	ui.client.set_process(false)
	ui.client.link = fake
	ui.client.authenticated = true
	ui.client.connected.emit()
	for _frame in range(3):
		await process_frame
	check(not ui.server_picker.visible and ui.settings_button.visible, "connection hides settings and keeps a settings button")
	check(ui.screen.get_global_rect().is_equal_approx(Rect2(Vector2.ZERO, ui.size)), "connected stream has no added margins")
	ui.settings_button.pressed.emit()
	await process_frame
	check(ui.server_picker.visible, "settings can be reopened while connected")
	ui.settings_button.pressed.emit()
	for _frame in range(3):
		await process_frame
	var image := Image.create(64, 32, false, Image.FORMAT_RGB8)
	ui._frame_received(image)
	var settings_touch := InputEventScreenTouch.new()
	settings_touch.pressed = true
	settings_touch.position = ui.settings_button.get_global_rect().get_center()
	ui._input(settings_touch)
	check(fake.messages.is_empty(), "settings button touch is not sent to game")
	ui.license_panel.show()
	settings_touch.position = ui._image_rect().get_center()
	ui._input(settings_touch)
	check(fake.messages.is_empty(), "license screen does not forward touches")
	ui.license_panel.hide()
	var notices := preload("res://license_notices.gd").full_text()
	check(notices.contains("2020-2022 DmitriySalnikov") and notices.contains(Engine.get_license_text()) and notices.contains("Third-party component notices"), "offline notices include original MIT and engine licenses")
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
	check(ui.server_picker.visible and not ui.settings_button.visible, "disconnect restores connection settings")
	ui.queue_free()
	await process_frame
	print("Mobile UI failures: %d" % failures)
	quit(0 if failures == 0 else 1)
