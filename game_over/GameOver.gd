extends Control

onready var trophies = {
	"gold": {
		"label": $GameStats/TrophiesHBoxContainer/GoldTrophyLabel,
		"icon": $GameStats/TrophiesHBoxContainer/GoldTrophyTextureRect,
		"count": 0
	},
	"silver": {
		"label": $GameStats/TrophiesHBoxContainer/SilverTrophyLabel,
		"icon": $GameStats/TrophiesHBoxContainer/SilverTrophyTextureRect,
		"count": 0
	},
	"bronze": {
		"label": $GameStats/TrophiesHBoxContainer/BronzeTrophyLabel,
		"icon": $GameStats/TrophiesHBoxContainer/BronzeTrophyTextureRect,
		"count": 0
	}
}
onready var steps_taken_label = $GameStats/StepsTakenHBoxContainer/StepsTakenValueLabel
onready var animation_player = $AnimationPlayer

var count_steps = 0
var can_continue = false

func _ready():
	for level_name in Global.player_steps:
		var steps = Global.player_steps[level_name]
		var req = Global.LEVEL_TROPHY_REQUIREMENTS[level_name]
		
		count_steps += steps

		if steps <= req.gold:
			trophies.gold.count += 1
		elif steps <= req.silver:
			trophies.silver.count += 1
		else:
			trophies.bronze.count += 1

	for t in trophies.values():
		if t.count == 0:
			t.label.queue_free()
			t.icon.queue_free()
		else:
			t.label.text = str(t.count) + "x"

	steps_taken_label.text += str(count_steps)

func _on_AnimationPlayer_animation_finished(_anim_name):
	if can_continue: get_tree().change_scene("res://levels/level00.tscn")
	else: can_continue = true
	
func _input(event):
	if animation_player.is_playing(): return

	if event is InputEventMouseButton and event.pressed:
		animation_player.play_backwards("fade_in")

	if event is InputEventKey and event.pressed:
		animation_player.play_backwards("fade_in")
