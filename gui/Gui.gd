extends Control

onready var level = $".."
onready var player = level.get_node("Objects/Player")

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Undo_pressed():
	if not player.tween or not player.tween.is_running():
		level.undo()
