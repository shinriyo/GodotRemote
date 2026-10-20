extends Node

signal servers_changed(servers: Array)
signal status_changed(message: String)

const BRIDGE_PORT := 22767
const TIMEOUT_MSEC := 5000
var _socket := PacketPeerUDP.new()
var _servers: Array = []
var _last_packet := 0
var _state := ""

func _ready() -> void:
	if not OS.has_feature("ios"):
		_status("Automatic discovery is available in the iPhone app. You can also enter an address.")
		set_process(false)
		return
	start()

func start(bridge_port: int = BRIDGE_PORT) -> Error:
	_socket.close()
	var error := _socket.bind(bridge_port, "127.0.0.1")
	_last_packet = Time.get_ticks_msec()
	_status("Searching for games on the same Wi-Fi…")
	if error != OK:
		_status("Discovery unavailable. Enter the Mac/PC address manually.")
	set_process(error == OK)
	return error

func _exit_tree() -> void:
	_socket.close()

func _process(_delta: float) -> void:
	for _i in range(mini(32, _socket.get_available_packet_count())):
		var packet := _socket.get_packet()
		if _socket.get_packet_ip() != "127.0.0.1":
			continue
		accept_snapshot(packet)
	if Time.get_ticks_msec() - _last_packet > TIMEOUT_MSEC:
		_update_servers([])
		_status("No discovery response. Check Local Network permission or enter an address.")

func accept_snapshot(packet: PackedByteArray) -> void:
	if packet.size() > 16384:
		return
	var json := JSON.new()
	if json.parse(packet.get_string_from_utf8()) != OK:
		return
	var value: Variant = json.data
	if not value is Dictionary or value.get("protocol") != 1 or not value.get("servers") is Array:
		return
	var entries: Array = []
	var seen := {}
	for item in value.servers.slice(0, 32):
		if not item is Dictionary:
			continue
		if not item.get("id") is String or not item.get("name") is String or not item.get("host") is String:
			continue
		if not (item.get("port") is float or item.get("port") is int):
			continue
		if item.port < 1 or item.port > 65535 or item.port != int(item.port):
			continue
		if item.id.length() > 512 or item.name.length() > 128 or item.host.length() > 253:
			continue
		if not item.host.is_valid_ip_address() and not item.host.trim_suffix(".").ends_with(".local"):
			continue
		if seen.has(item.id):
			continue
		seen[item.id] = true
		entries.append({"id": item.id, "name": item.name, "host": item.host, "port": int(item.port)})
	_last_packet = Time.get_ticks_msec()
	_update_servers(entries)
	if value.get("state") == "unavailable":
		_status("Discovery unavailable. Check Local Network permission or enter an address.")
	elif entries.is_empty():
		_status("Searching… Run a game with Godot Remote enabled on your Mac.")
	else:
		_status("Select a game, then press Connect.")

func _update_servers(entries: Array) -> void:
	if entries != _servers:
		_servers = entries
		servers_changed.emit(_servers.duplicate(true))

func _status(message: String) -> void:
	if message != _state:
		_state = message
		status_changed.emit(message)
