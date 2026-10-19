extends SceneTree

func _initialize() -> void:
	var scripts := ["link", "input_codec", "server", "client", "autoload", "plugin"]
	for name in scripts:
		var script = load("res://addons/godot_remote/%s.gd" % name)
		if script == null or not script.can_instantiate():
			quit(1)
			return
	for path in ["res://client_ui.gd", "res://demo_server.gd"]:
		var script = load(path)
		if script == null or not script.can_instantiate():
			quit(1)
			return
	print("PASS: all Godot 4 scripts compile")
	quit()
