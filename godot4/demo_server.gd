extends Control

const Server = preload("res://addons/godot_remote/server.gd")
var server := Server.new()
var position_label := Label.new()
var dot := Vector2(300, 300)
var time := 0.0

func _ready() -> void:
	add_child(server)
	var title := Label.new()
	title.text = "Godot Remote 4 — server demo\nConnect the client to this PC on port 22766.\nTouch/click the streamed screen to move the circle."
	title.position = Vector2(30, 30)
	title.add_theme_font_size_override("font_size", 22)
	add_child(title)
	position_label.position = Vector2(30, 140)
	add_child(position_label)
	server.client_connected.connect(func(): position_label.text = "Client connected")
	server.client_disconnected.connect(func(): position_label.text = "Client disconnected")
	var error := server.start()
	position_label.text = "Listening on port 22766" if error == OK else error_string(error)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouseButton:
		dot = event.position
		position_label.text = "Input: %s" % dot

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("172438"))
	draw_circle(dot, 40.0 + sin(time * 3.0) * 8.0, Color("60d5b2"))
