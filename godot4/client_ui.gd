extends Control

const RemoteClient = preload("res://addons/godot_remote/client.gd")
var client := RemoteClient.new()
var screen := TextureRect.new()
var status := Label.new()
var host := LineEdit.new()
var port := SpinBox.new()
var password := LineEdit.new()
var connect_button := Button.new()
var _active_pointers := {}
var _safe_margin := MarginContainer.new()

func _ready() -> void:
	add_child(client)
	DisplayServer.screen_set_keep_on(true)
	if OS.has_feature("mobile"):
		get_window().content_scale_size = Vector2i(390, 390)
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	add_child(_safe_margin)
	_safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	_safe_margin.add_child(layout)
	get_viewport().size_changed.connect(_update_safe_area)
	_update_safe_area.call_deferred()
	var toolbar := HFlowContainer.new()
	layout.add_child(toolbar)
	host.placeholder_text = "PC IP address"
	host.text = "" if OS.has_feature("mobile") else "127.0.0.1"
	host.custom_minimum_size.x = 200
	toolbar.add_child(host)
	port.min_value = 1024
	port.max_value = 65535
	port.value = 22766
	toolbar.add_child(port)
	password.placeholder_text = "Password"
	password.secret = true
	password.custom_minimum_size.x = 140
	toolbar.add_child(password)
	connect_button.text = "Connect"
	connect_button.pressed.connect(_connect_pressed)
	toolbar.add_child(connect_button)
	var disconnect_button := Button.new()
	disconnect_button.text = "Disconnect"
	disconnect_button.pressed.connect(func(): client.disconnect_from_host())
	toolbar.add_child(disconnect_button)
	status.text = "Enter the Mac/PC IP address on the same Wi-Fi."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status)
	screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(screen)
	for control in [host, port, password, connect_button, disconnect_button]:
		control.custom_minimum_size.y = 48
	var saved := ConfigFile.new()
	if saved.load("user://connection.cfg") == OK:
		host.text = saved.get_value("connection", "host", host.text)
		port.value = saved.get_value("connection", "port", port.value)
	client.connected.connect(func(): status.text = "Connected — waiting for video"; connect_button.disabled = false)
	client.disconnected.connect(func(reason): status.text = reason; screen.texture = null; _active_pointers.clear(); connect_button.disabled = false)
	client.frame_received.connect(_frame_received)

func _connect_pressed() -> void:
	if host.text.strip_edges().is_empty():
		status.text = "Enter the Mac/PC IP address first."
		return
	var saved := ConfigFile.new()
	saved.set_value("connection", "host", host.text.strip_edges())
	saved.set_value("connection", "port", int(port.value))
	saved.save("user://connection.cfg")
	var error := client.connect_to_host(host.text.strip_edges(), int(port.value), password.text)
	status.text = "Connecting…" if error == OK else error_string(error)
	connect_button.disabled = error == OK
	get_viewport().gui_release_focus()
	DisplayServer.virtual_keyboard_hide()

func _frame_received(image: Image) -> void:
	if screen.texture is ImageTexture and screen.texture.get_size() == Vector2(image.get_size()):
		screen.texture.update(image)
	else:
		screen.texture = ImageTexture.create_from_image(image)
	status.text = "Connected — %d × %d" % [image.get_width(), image.get_height()]

func _image_rect() -> Rect2:
	if not screen.texture:
		return Rect2()
	var image_size := screen.texture.get_size()
	var factor := minf(screen.size.x / image_size.x, screen.size.y / image_size.y)
	var shown := image_size * factor
	return Rect2(screen.global_position + (screen.size - shown) * 0.5, shown)

func _input(event: InputEvent) -> void:
	# GUI buttons need emulated mouse events on mobile; do not forward them
	# alongside the original touch event to the remote game.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if not client.authenticated or not screen.texture:
		return
	var rect := _image_rect()
	var pointer := ""
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		pointer = "touch:%s" % event.index
	elif event is InputEventMouseButton:
		pointer = "mouse:%s" % event.button_index
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			if not rect.has_point(event.position):
				return
			_active_pointers[pointer] = true
		elif not _active_pointers.has(pointer):
			return
		else:
			_active_pointers.erase(pointer)
	elif event is InputEventScreenDrag:
		if not _active_pointers.has(pointer):
			return
	elif event is InputEventMouseMotion:
		if not rect.has_point(event.position) and _active_pointers.is_empty():
			return
	elif event is InputEventKey:
		if get_viewport().gui_get_focus_owner() != null:
			return
	else:
		return
	client.send_input(event, rect)
	get_viewport().set_input_as_handled()

func _update_safe_area() -> void:
	var insets := Vector4.ZERO
	if OS.has_feature("mobile"):
		var safe := Rect2(DisplayServer.get_display_safe_area())
		var window_size := Vector2(DisplayServer.window_get_size())
		insets = safe_area_insets(safe, window_size, size)
	_safe_margin.add_theme_constant_override("margin_left", int(insets.x) + 8)
	_safe_margin.add_theme_constant_override("margin_top", int(insets.y) + 8)
	_safe_margin.add_theme_constant_override("margin_right", int(insets.z) + 8)
	_safe_margin.add_theme_constant_override("margin_bottom", int(insets.w) + 8)

static func safe_area_insets(safe: Rect2, window_size: Vector2, logical_size: Vector2) -> Vector4:
	if window_size.x <= 0 or window_size.y <= 0 or not safe.has_area():
		return Vector4.ZERO
	var ratio := logical_size / window_size
	return Vector4(maxf(0, safe.position.x) * ratio.x, maxf(0, safe.position.y) * ratio.y,
		maxf(0, window_size.x - safe.end.x) * ratio.x, maxf(0, window_size.y - safe.end.y) * ratio.y)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		client.disconnect_from_host("Disconnected while app is in background")
