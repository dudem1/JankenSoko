extends Control

onready var level = $".."
onready var player = $"../Contain/Objects/Player"
onready var level_animation_player = $"../AnimationPlayer"
onready var steps = $Steps
onready var steps_animation_player = $Steps/AnimationPlayer
onready var back_button = $Back
onready var restart_button = $Restart
onready var undo_button = $Undo
onready var info_button = $Info
onready var click_sound = $ClickSound

var button_tweens = {}

func _ready():
	if level.name == "Level00":
		steps.visible = false
		back_button.queue_free()
		restart_button.queue_free()
		undo_button.queue_free()

	steps_animation_player.playback_speed = Global.speed

	click_sound.pitch_scale = Global.adjust_pitch(click_sound)

	_setup_hover(back_button)
	_setup_hover(restart_button)
	_setup_hover(undo_button)
	_setup_hover(info_button)

func _setup_hover(button):
	button.connect("mouse_entered", self, "_on_button_hover_on", [button])
	button.connect("mouse_exited", self, "_on_button_hover_off", [button])
	button.connect("button_down", self, "_on_button_hover_on", [button])
	button.connect("button_up", self, "_on_button_hover_off", [button])

func _on_button_hover_on(button):
	_animate_button(button, -20.0)

func _on_button_hover_off(button):
	_animate_button(button, 0.0)

func _animate_button(button, target_deg):
	if button in button_tweens and button_tweens[button]:
		button_tweens[button].stop_all()
		button_tweens[button].queue_free()

	var t = Tween.new()
	add_child(t)
	button_tweens[button] = t

	t.interpolate_property(
		button,
		"rect_rotation",
		button.rect_rotation,
		target_deg,
		1.0 / Global.speed,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	t.start()

func _on_Restart_pressed():
	if !player.can_move: return
	
	click_sound.play()

	player.can_move = false
	level_animation_player.play("restart_level")

func _on_Undo_pressed():
	if !player.can_move: return

	click_sound.play()

	if player.tween and player.tween.is_running(): return

	level.undo()

func _on_Info_pressed():
	if !player.can_move: return

	click_sound.play()

	print("info")

func _on_Back_pressed():
	print("back")
