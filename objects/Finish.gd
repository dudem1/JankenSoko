extends Area2D

onready var finish_sound = $FinishSound
onready var finish_panel = $"../../../Gui/FinishPanel"
onready var animation_player_finish_panel = $"../../../Gui/FinishPanel/AnimationPlayer"

func _ready():
	finish_sound.pitch_scale = Global.adjust_pitch(finish_sound)

	animation_player_finish_panel.playback_speed = Global.speed

func _on_Finish_area_entered(area):
	if area.is_in_group("player"):
		var player = area

		player.can_move = false

		finish_sound.play()

		animation_player_finish_panel.play("fade_in")
