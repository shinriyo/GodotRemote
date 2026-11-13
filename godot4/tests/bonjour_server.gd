extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var server = load("res://addons/godot_remote/server.gd").new()
	root.add_child(server)
	server.capture_enabled = false
	if server.start(24768) != OK or server._bonjour_pid <= 0:
		push_error("Bonjour test server failed to start")
		quit(1)
		return
	await create_timer(7.0).timeout
	server.stop()
	server.queue_free()
	quit()
