extends Area2D

onready var finish_sound = $FinishSound
onready var finish_panel = $"../../../Gui/FinishPanel"
onready var level = $"../../.."
onready var animation_player = $"../../../AnimationPlayer"

func _ready():
	finish_sound.pitch_scale = Global.adjust_pitch(finish_sound)

func _on_Finish_area_entered(area):
	if !area.is_in_group("player"): return

	var player = area
	player.can_move = false
	finish_sound.play()

	if level.name == "Level00":
		level.selected_level = self.name
		animation_player.play("end_level")
	else:
		finish_panel.visible = 1
		Global.save_steps(level.name, level.history.size())
