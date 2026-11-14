extends Control

const RemoteClient = preload("res://addons/godot_remote/client.gd")
const Discovery = preload("res://addons/godot_remote/discovery.gd")
var discovery := Discovery.new()
var server_picker := OptionButton.new()
var discovery_status := Label.new()
var _discovered: Array = []
var client := RemoteClient.new()
var screen := TextureRect.new()
var status := Label.new()
var host := LineEdit.new()
var port := SpinBox.new()
var password := LineEdit.new()
var _paste_target: LineEdit
var connect_button := Button.new()
var _active_pointers := {}
var _safe_margin := MarginContainer.new()
var settings_button := Button.new()
var _settings_controls: Array[Control] = []
var license_panel := PanelContainer.new()
var _license_margin := MarginContainer.new()

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
	server_picker.custom_minimum_size.y = 48
	server_picker.fit_to_longest_item = false
	server_picker.clip_text = true
	server_picker.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	server_picker.add_item("Find a running game…")
	server_picker.disabled = true
	server_picker.item_selected.connect(_server_selected)
	server_picker.get_popup().about_to_popup.connect(_refresh_server_labels)
	layout.add_child(server_picker)
	discovery_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(discovery_status)
	discovery.servers_changed.connect(_servers_changed)
	discovery.status_changed.connect(func(message): discovery_status.text = message)
	add_child(discovery)
	var toolbar := VBoxContainer.new()
	layout.add_child(toolbar)
	var host_row := HBoxContainer.new()
	toolbar.add_child(host_row)
	var host_label := Label.new()
	host_label.text = "Host"
	host_label.custom_minimum_size.x = 92
	host_row.add_child(host_label)
	host.placeholder_text = "PC IP or hostname"
	host.clear_button_enabled = true
	host.text = "" if OS.has_feature("mobile") else "127.0.0.1"
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.focus_entered.connect(func(): _paste_target = host)
	host_row.add_child(host)
	var host_paste_button := Button.new()
	host_paste_button.text = "Paste"
	host_paste_button.pressed.connect(func(): _paste_into_field(host))
	host_row.add_child(host_paste_button)
	var port_row := HBoxContainer.new()
	toolbar.add_child(port_row)
	var port_label := Label.new()
	port_label.text = "Port"
	port_label.custom_minimum_size.x = 92
	port_row.add_child(port_label)
	port.min_value = 1
	port.max_value = 65535
	port.value = 22766
	port.custom_minimum_size.x = 110
	port.get_line_edit().virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	port_row.add_child(port)
	var password_row := HBoxContainer.new()
	toolbar.add_child(password_row)
	var password_label := Label.new()
	password_label.text = "Password"
	password_label.custom_minimum_size.x = 92
	password_row.add_child(password_label)
	password.placeholder_text = "Password"
	password.clear_button_enabled = true
	password.secret = true
	password.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	password.focus_entered.connect(func(): _paste_target = password)
	password_row.add_child(password)
	var password_visibility_button := Button.new()
	var eye_icon: Texture2D = load("res://eye.svg")
	var eye_off_icon: Texture2D = load("res://eye_off.svg")
	password_visibility_button.icon = eye_icon
	password_visibility_button.custom_minimum_size.x = 52
	password_visibility_button.tooltip_text = "Show or hide password"
	password_visibility_button.pressed.connect(func():
		password.secret = not password.secret
		password_visibility_button.icon = eye_icon if password.secret else eye_off_icon
	)
	password_row.add_child(password_visibility_button)
	var password_paste_button := Button.new()
	password_paste_button.text = "Paste"
	password_paste_button.pressed.connect(func(): _paste_into_field(password))
	password_row.add_child(password_paste_button)
	var action_row := HBoxContainer.new()
	toolbar.add_child(action_row)
	connect_button.text = "Connect"
	connect_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connect_button.icon = load("res://connect.svg")
	connect_button.modulate = Color("#86e6ad")
	connect_button.pressed.connect(_connect_pressed)
	action_row.add_child(connect_button)
	var disconnect_button := Button.new()
	disconnect_button.text = "Disconnect"
	disconnect_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	disconnect_button.icon = load("res://disconnect.svg")
	disconnect_button.modulate = Color("#f28b8b")
	disconnect_button.hide()
	disconnect_button.pressed.connect(func(): client.disconnect_from_host())
	action_row.add_child(disconnect_button)
	var licenses_button := Button.new()
	licenses_button.text = "About"
	licenses_button.tooltip_text = "App information and licenses"
	licenses_button.flat = true
	licenses_button.add_theme_font_size_override("font_size", 14)
	licenses_button.custom_minimum_size = Vector2(64, 44)
	licenses_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	licenses_button.pressed.connect(func(): license_panel.show(); get_viewport().gui_release_focus())
	status.text = "Enter the Mac/PC address on the same local network."
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status)
	screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(screen)
	layout.add_child(licenses_button)
	_settings_controls.assign([server_picker, discovery_status, toolbar, status, licenses_button])
	settings_button.text = "Settings"
	settings_button.custom_minimum_size = Vector2(96, 48)
	settings_button.size = Vector2(96, 48)
	settings_button.focus_mode = Control.FOCUS_NONE
	settings_button.hide()
	settings_button.pressed.connect(func(): _show_settings(not server_picker.visible))
	add_child(settings_button)
	for control in [host, host_paste_button, port, password, password_visibility_button, password_paste_button, connect_button, disconnect_button]:
		control.custom_minimum_size.y = 48
	var saved := ConfigFile.new()
	if saved.load("user://connection.cfg") == OK:
		host.text = saved.get_value("connection", "host", host.text)
		port.value = saved.get_value("connection", "port", port.value)
	client.connected.connect(func():
		status.text = "Connected — waiting for video"
		connect_button.hide()
		disconnect_button.show()
		_show_settings(false)
	)
	client.disconnected.connect(func(reason):
		status.text = reason
		screen.texture = null
		_active_pointers.clear()
		disconnect_button.hide()
		connect_button.show()
		connect_button.disabled = false
		_show_settings(true)
	)
	client.frame_received.connect(_frame_received)
	_build_license_panel()

func _build_license_panel() -> void:
	add_child(license_panel)
	license_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := StyleBoxFlat.new()
	background.bg_color = Color("101d32")
	license_panel.add_theme_stylebox_override("panel", background)
	license_panel.add_child(_license_margin)
	for edge in ["left", "right", "top", "bottom"]:
		_license_margin.add_theme_constant_override("margin_" + edge, 24)
	var column := VBoxContainer.new()
	_license_margin.add_child(column)
	var heading := Label.new()
	heading.text = ProjectSettings.get_setting("application/config/name")
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(heading)
	var notices := RichTextLabel.new()
	notices.bbcode_enabled = false
	notices.selection_enabled = true
	notices.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notices.text = preload("res://license_notices.gd").full_text()
	column.add_child(notices)
	var privacy := Button.new()
	privacy.text = "Privacy Policy"
	privacy.custom_minimum_size.y = 48
	privacy.pressed.connect(func(): OS.shell_open("https://shinriyo-remote.netlify.app/privacy-en.html"))
	column.add_child(privacy)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size.y = 48
	close.pressed.connect(func(): license_panel.hide(); get_viewport().gui_release_focus())
	column.add_child(close)
	license_panel.hide()


func _show_settings(show_panel: bool) -> void:
	for control in _settings_controls:
		control.visible = show_panel
	_update_safe_area()
	settings_button.visible = client.authenticated
	settings_button.text = "Hide" if show_panel else "Settings"
	get_viewport().gui_release_focus()
	DisplayServer.virtual_keyboard_hide()

func _connect_pressed() -> void:
	if "://" in host.text:
		status.text = "Use your Mac/PC local IP address, not a web URL."
		return
	if host.text.strip_edges().is_empty():
		status.text = "Enter the Mac/PC IP address or hostname first."
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

func _paste_into_field(field: LineEdit) -> void:
	var clipboard := DisplayServer.clipboard_get()
	if clipboard.is_empty():
		status.text = "Clipboard is empty."
		return
	field.text = clipboard
	field.caret_column = field.text.length()
	_paste_target = field
	status.text = "Pasted."

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
	if license_panel.visible or not client.authenticated or not screen.texture:
		return
	var rect := _image_rect()
	var pointer := ""
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		pointer = "touch:%s" % event.index
	elif event is InputEventMouseButton:
		pointer = "mouse:%s" % event.button_index
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			if (settings_button.visible and settings_button.get_global_rect().has_point(event.position)) or not rect.has_point(event.position):
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
		if _active_pointers.is_empty() and ((settings_button.visible and settings_button.get_global_rect().has_point(event.position)) or not rect.has_point(event.position)):
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
	_license_margin.add_theme_constant_override("margin_left", int(insets.x) + 24)
	_license_margin.add_theme_constant_override("margin_top", int(insets.y) + 24)
	_license_margin.add_theme_constant_override("margin_right", int(insets.z) + 24)
	_license_margin.add_theme_constant_override("margin_bottom", int(insets.w) + 24)
	var padding := 8 if server_picker.visible else 0
	_safe_margin.add_theme_constant_override("margin_left", int(insets.x) + padding)
	_safe_margin.add_theme_constant_override("margin_top", int(insets.y) + (60 if server_picker.visible and client.authenticated else padding))
	_safe_margin.add_theme_constant_override("margin_right", int(insets.z) + padding)
	_safe_margin.add_theme_constant_override("margin_bottom", int(insets.w) + padding)

	settings_button.position = Vector2(size.x - insets.z - 104, insets.y + 8)

static func safe_area_insets(safe: Rect2, window_size: Vector2, logical_size: Vector2) -> Vector4:
	if window_size.x <= 0 or window_size.y <= 0 or not safe.has_area():
		return Vector4.ZERO
	var ratio := logical_size / window_size
	return Vector4(maxf(0, safe.position.x) * ratio.x, maxf(0, safe.position.y) * ratio.y,
		maxf(0, window_size.x - safe.end.x) * ratio.x, maxf(0, window_size.y - safe.end.y) * ratio.y)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		client.disconnect_from_host("Disconnected while app is in background")

func _servers_changed(servers: Array) -> void:
	var selected_id := ""
	if server_picker.selected > 0 and server_picker.selected <= _discovered.size():
		selected_id = _discovered[server_picker.selected - 1].id
	_discovered = servers
	server_picker.clear()
	server_picker.add_item("Select a running game…")
	for entry in servers:
		server_picker.add_item(_server_label(entry))
		server_picker.set_item_tooltip(server_picker.item_count - 1, "%s:%d" % [entry.host, entry.port])
		if entry.id == selected_id:
			server_picker.select(server_picker.item_count - 1)
	server_picker.disabled = servers.is_empty()

func _server_selected(index: int) -> void:
	if index <= 0 or index > _discovered.size():
		return
	var entry: Dictionary = _discovered[index - 1]
	host.text = entry.host
	port.value = entry.port
	get_viewport().gui_release_focus()

func _server_label(entry: Dictionary) -> String:
	var label: String = entry.name
	var font := server_picker.get_theme_font("font")
	var font_size := server_picker.get_theme_font_size("font_size")
	var max_width := maxf(80.0, get_viewport().get_visible_rect().size.x - 100.0)
	if font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= max_width:
		return label
	while label.length() > 1 and font.get_string_size(label + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
		label = label.left(label.length() - 1)
	return label + "…"

func _refresh_server_labels() -> void:
	for index in _discovered.size():
		server_picker.set_item_text(index + 1, _server_label(_discovered[index]))
