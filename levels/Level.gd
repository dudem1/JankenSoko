extends Node2D

var history = []

func save_state():
	var state = {}

	for obj in $Objects.get_children():
		state[obj.get_path()] = {
			"position": obj.position,
			"visible": obj.visible
		}

	if history.empty() or is_state_different(history[history.size() - 1], state):
		history.append(state)

func is_state_different(state_a: Dictionary, state_b: Dictionary) -> bool:
	if state_a.keys() != state_b.keys():
		return true

	for path in state_a.keys():
		if state_a[path]["position"] != state_b[path]["position"]:
			return true
		if state_a[path]["visible"] != state_b[path]["visible"]:
			return true

	return false

func undo():
	if history.empty(): return

	var state = history.pop_back()

	for path in state.keys():
		if has_node(path):
			var obj = get_node(path)
			obj.position = state[path]["position"]
			if state[path]["visible"] and obj.has_method("activate"):
				obj.activate()
