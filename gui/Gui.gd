extends Control

onready var level = $".."
onready var player = $"../Contain/Objects/Player"

func _on_Restart_pressed():
	player.can_move = false
	get_tree().reload_current_scene()

func _on_Undo_pressed():
	if level.history.empty(): return

	if not player.tween or not player.tween.is_running():
		level.undo()
