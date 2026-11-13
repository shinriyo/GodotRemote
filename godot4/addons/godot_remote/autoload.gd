extends "res://addons/godot_remote/server.gd"

func _ready() -> void:
	if not OS.is_debug_build() or not ProjectSettings.get_setting("godot_remote/server/enabled", true):
		return
	password = ProjectSettings.get_setting("godot_remote/server/password", "")
	fps = ProjectSettings.get_setting("godot_remote/server/fps", 20)
	quality = ProjectSettings.get_setting("godot_remote/server/quality", 0.65)
	image_scale = ProjectSettings.get_setting("godot_remote/server/scale", 0.5)
	var error := start(ProjectSettings.get_setting("godot_remote/server/port", 22766))
	if error != OK:
		push_error("Godot Remote: cannot listen (%s)" % error_string(error))
