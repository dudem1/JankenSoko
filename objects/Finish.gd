extends Area2D

onready var finish_sound = $FinishSound
onready var finish_panel = $"../../../Gui/FinishPanel"

func _ready():
	finish_sound.pitch_scale = Global.adjust_pitch(finish_sound)

func _on_Finish_area_entered(area):
	if area.is_in_group("player"):
		var player = area

		player.can_move = false
		
		finish_sound.play()
		
		finish_panel.visible = 1
