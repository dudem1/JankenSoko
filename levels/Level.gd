extends Node2D

const MAX_HISTORY = 1000
var history = []
var selected_level = "Level00"
onready var steps_label = $Gui/Steps/Label
onready var steps_animation_player = $Gui/Steps/AnimationPlayer
onready var objects = $Contain/Objects
onready var player = $Contain/Objects/Player
onready var map = $Contain/Map
onready var animation_player = $AnimationPlayer

func _ready():
	if self.name == "Level00":
		if Global.back_from_level != "Level00":
			player.position = objects.get_node("BackFrom" + Global.back_from_level).position

		if !Global.play_intro_animation:
			$Intro.queue_free()
			animation_player.play("start_level")

		for level_name in Global.player_steps:
			var steps = Global.player_steps[level_name]

			if steps > 0:
				if level_name != "Level11":
					objects.get_node("Lock" + level_name).queue_free()
			
			objects.get_node("Trophy" + level_name).modulate = Global.set_trophy(level_name, Global.player_steps.get(level_name, 0))

	Global.back_from_level = self.name

func change_steps():
	var steps = history.size()

	if steps > 999:
		steps_label.text = "999+"
	else:
		steps_label.text = str(steps)

	steps_animation_player.play("change")

func save_state():
	var state = {}
	var active = true

	for obj in objects.get_children():
		if obj.has_method("activate"): active = obj.active

		state[obj.get_path()] = {
			"position": obj.position,
			"active": active
		}

	history.append(state)

	if history.size() > MAX_HISTORY: history.pop_front()

	change_steps()

func undo():
	if history.empty(): return

	var state = history.pop_back()

	change_steps()

	for path in state.keys():
		if has_node(path):
			var obj = get_node(path)

			if obj.has_method("activate") and !obj.active and state[path]["active"]:
				obj.activate()

			var target_pos = state[path]["position"]

			if obj.position == target_pos: continue

			obj.tween.kill()
			obj.tween = null
			obj.tween = obj.create_tween()
			obj.tween.set_trans(Tween.TRANS_SINE)
			obj.tween.set_ease(Tween.EASE_IN_OUT)
			obj.tween.tween_property(
				obj,
				"position",
				target_pos,
				1.0 / Global.speed
			)

func is_walkable_position(world_position: Vector2) -> bool:
	var tile = map.get_cellv(map.world_to_map(world_position))
	return tile == 1

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"intro":
			$Intro.queue_free()
			player.can_move = true
			Global.play_intro_animation = false
			Global.timer_running = true
		"start_level": player.can_move = true
		"restart_level": get_tree().reload_current_scene()
		"end_level":
			if self.name == "Level11":
				get_tree().change_scene("res://game_over/GameOver.tscn")
			else:
				get_tree().change_scene("res://levels/"+selected_level+".tscn")
