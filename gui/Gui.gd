extends Control

onready var level = $".."
onready var player = $"../Contain/Objects/Player"
onready var animation_player = $"../AnimationPlayer"

func _on_Restart_pressed():
	player.can_move = false
	animation_player.play("restart_level")

func _on_Undo_pressed():
	if level.history.empty(): return

	if not player.tween or not player.tween.is_running():
		level.undo()
