extends SceneTree

const Discovery = preload("res://addons/godot_remote/discovery.gd")
const UI = preload("res://client_ui.gd")
var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(value: bool, label: String) -> void:
	if value:
		print("PASS: " + label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var discovery := Discovery.new()
	root.add_child(discovery)
	var first := {"id": "one", "name": "Game One", "host": "192.168.1.12", "port": 22766}
	var second := {"id": "two", "name": "Game Two", "host": "mac.local.", "port": 22768}
	discovery.accept_snapshot(JSON.stringify({"protocol": 1, "servers": [first, second]}).to_utf8_buffer())
	check(discovery._servers.size() == 2, "multiple games and local hostname accepted")
	discovery.accept_snapshot(JSON.stringify({"protocol": 99, "servers": []}).to_utf8_buffer())
	check(discovery._servers.size() == 2, "unknown bridge version ignored")
	discovery.accept_snapshot("not json".to_utf8_buffer())
	check(discovery._servers.size() == 2, "malformed packet ignored")
	var invalid := first.duplicate()
	invalid.port = 99999
	discovery.accept_snapshot(JSON.stringify({"protocol": 1, "servers": [first, first, invalid, {}]}).to_utf8_buffer())
	check(discovery._servers.size() == 1, "invalid endpoints and duplicates filtered")
	var ui := UI.new()
	root.add_child(ui)
	ui._servers_changed([first, second])
	ui._server_selected(2)
	check(ui.host.text == "mac.local." and ui.port.value == 22768, "selected game fills host and port without typing")
	check(not ui.client.authenticated, "selection does not connect without user action")
	ui.server_picker.select(2)
	ui._servers_changed([second, first])
	check(ui.server_picker.selected == 1, "selection survives reordered discovery results")
	ui._servers_changed([])
	check(ui.server_picker.disabled, "empty server list is disabled")
	check(discovery.start(24769) == OK, "discovery bridge binds loopback only")
	discovery._last_packet = Time.get_ticks_msec() - 6000
	discovery._process(0)
	check(discovery._servers.is_empty(), "stale native bridge results expire")
	discovery.queue_free()
	ui.queue_free()
	await process_frame
	print("Discovery failures: %d" % failures)
	quit(0 if failures == 0 else 1)
