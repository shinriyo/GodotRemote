extends RefCounted

static func encode(event: InputEvent, area: Rect2) -> Dictionary:
	var data := {}
	if event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse:
		if area.size.x <= 0 or area.size.y <= 0:
			return {}
		data["position"] = (event.position - area.position) / area.size
	if event is InputEventScreenTouch:
		data.merge({"type": "touch", "index": event.index, "pressed": event.pressed})
	elif event is InputEventScreenDrag:
		data.merge({"type": "drag", "index": event.index, "relative": event.relative / area.size})
	elif event is InputEventMouseButton:
		data.merge({"type": "button", "button": event.button_index, "pressed": event.pressed, "double": event.double_click})
	elif event is InputEventMouseMotion:
		data.merge({"type": "motion", "relative": event.relative / area.size, "mask": event.button_mask})
	elif event is InputEventKey:
		data.merge({"type": "key", "keycode": event.keycode, "physical": event.physical_keycode, "unicode": event.unicode, "pressed": event.pressed, "echo": event.echo})
	else:
		return {}
	if event is InputEventWithModifiers:
		data.merge({"shift": event.shift_pressed, "ctrl": event.ctrl_pressed, "alt": event.alt_pressed, "meta": event.meta_pressed})
	return data

static func decode(data: Dictionary, size: Vector2) -> InputEvent:
	var kind: Variant = data.get("type")
	var event: InputEvent
	if kind in ["touch", "drag", "button", "motion"]:
		if not data.get("position") is Vector2 or not data.position.is_finite():
			return null
	if kind in ["drag", "motion"]:
		if not data.get("relative") is Vector2 or not data.relative.is_finite():
			return null
	if kind in ["touch", "drag"]:
		if not data.get("index") is int or data.index < 0 or data.index > 31:
			return null
	if kind in ["touch", "button", "key"] and not data.get("pressed") is bool:
		return null
	match kind:
		"touch":
			event = InputEventScreenTouch.new()
			event.index = data.index
			event.pressed = data.pressed
		"drag":
			event = InputEventScreenDrag.new()
			event.index = data.index
			event.relative = data.relative * size
		"button":
			if not data.get("button") is int or data.button < 1 or data.button > 9:
				return null
			event = InputEventMouseButton.new()
			event.button_index = data.button
			event.pressed = data.pressed
			event.double_click = data.get("double", false) == true
		"motion":
			if not data.get("mask") is int:
				return null
			event = InputEventMouseMotion.new()
			event.relative = data.relative * size
			event.button_mask = data.mask
		"key":
			for field in ["keycode", "physical", "unicode"]:
				if not data.get(field) is int:
					return null
			event = InputEventKey.new()
			event.keycode = data.keycode
			event.physical_keycode = data.physical
			event.unicode = data.unicode
			event.pressed = data.pressed
			event.echo = data.get("echo", false) == true
		_:
			return null
	if kind in ["touch", "drag", "button", "motion"]:
		event.position = data.position * size
	if event is InputEventMouse:
		event.global_position = event.position
	if event is InputEventWithModifiers:
		event.shift_pressed = data.get("shift", false) == true
		event.ctrl_pressed = data.get("ctrl", false) == true
		event.alt_pressed = data.get("alt", false) == true
		event.meta_pressed = data.get("meta", false) == true
	return event
