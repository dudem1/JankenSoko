extends Control

onready var level_manager = $".."

func _on_Restart_pressed():
	get_tree().reload_current_scene()

func _on_Undo_pressed():
	level_manager.undo()
