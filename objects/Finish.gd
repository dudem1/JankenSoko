extends Area2D

onready var finish_sound = $FinishSound
onready var finish_panel = $"../../../Gui/FinishPanel"
onready var finish_panel_animation_player = $"../../../Gui/FinishPanel/AnimationPlayer"
onready var level = $"../../.."
onready var level_animation_player = $"../../../AnimationPlayer"

func _ready():
	finish_sound.pitch_scale = Global.adjust_pitch(finish_sound)

func _on_Finish_area_entered(area):
	if !area.is_in_group("player"): return

	var player = area
	player.can_move = false
	finish_sound.play()

	if level.name == "Level00":
		level.selected_level = self.name
		level_animation_player.play("end_level")
	else:
		Global.save_steps(level.name, level.history.size())
		finish_panel.get_node("Trophy").modulate = Global.set_trophy(level.name, level.history.size())
		finish_panel.get_node("TrophyLabel").text = Global.get_steps_to_next_trophy(level.name, level.history.size())
		finish_panel_animation_player.play("show_and_hide")
