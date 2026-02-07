extends Node2D

var history = []

func save_state():
	var state = {}

	for obj in $Objects.get_children():
		state[obj.get_path()] = {
			"position": obj.position,
			"visible": obj.visible
		}

	history.append(state)

func undo():
	if history.empty(): return

	var state = history.pop_back()

	for path in state.keys():
		if has_node(path):
			var obj = get_node(path)
			obj.position = state[path]["position"]
			obj.visible = state[path]["visible"]
			obj.set_deferred("monitoring", obj.visible)
