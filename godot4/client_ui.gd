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

func _ready() -> void:
	add_child(client)
	DisplayServer.screen_set_keep_on(true)
	var layout := VBoxContainer.new()
	add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var toolbar := HFlowContainer.new()
	layout.add_child(toolbar)
	host.placeholder_text = "PC IP address"
	host.text = "127.0.0.1"
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
	status.text = "Enter the PC address (same Wi-Fi), or use 127.0.0.1 with adb reverse."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status)
	screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(screen)
	client.connected.connect(func(): status.text = "Connected — waiting for video"; connect_button.disabled = false)
	client.disconnected.connect(func(reason): status.text = reason; screen.texture = null; _active_pointers.clear(); connect_button.disabled = false)
	client.frame_received.connect(_frame_received)

func _connect_pressed() -> void:
	var error := client.connect_to_host(host.text.strip_edges(), int(port.value), password.text)
	status.text = "Connecting…" if error == OK else error_string(error)
	connect_button.disabled = error == OK
	get_viewport().gui_release_focus()

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
