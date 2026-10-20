@tool
extends EditorPlugin

func _enter_tree() -> void:
	var defaults := {"enabled": true, "port": 22766, "password": "", "fps": 20, "quality": 0.65, "scale": 0.5}
	for key in defaults:
		var setting: String = "godot_remote/server/" + key
		if not ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, defaults[key])
		ProjectSettings.set_initial_value(setting, defaults[key])
	if not ProjectSettings.has_setting("autoload/GodotRemote"):
		add_autoload_singleton("GodotRemote", "res://addons/godot_remote/autoload.gd")
	ProjectSettings.save()

func _disable_plugin() -> void:
	remove_autoload_singleton("GodotRemote")
	ProjectSettings.save()
