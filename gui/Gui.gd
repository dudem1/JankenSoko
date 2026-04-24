extends Control

onready var level = $".."
onready var player = $"../Contain/Objects/Player"
onready var level_animation_player = $"../AnimationPlayer"
onready var steps = $Steps
onready var steps_animation_player = $Steps/AnimationPlayer
onready var menu_button = $Menu
onready var menu_panel = $MenuPanel
onready var menu_panel_vbox_container = $MenuPanel/VBoxContainer
onready var select_level_button = $MenuPanel/VBoxContainer/SelectLevelButton
onready var restart_level_button = $MenuPanel/VBoxContainer/RestartLevelButton
onready var mute_music_button = $MenuPanel/VBoxContainer/MuteMusicButton
onready var mute_sounds_button = $MenuPanel/VBoxContainer/MuteSoundsButton
onready var controls_button = $MenuPanel/VBoxContainer/ControlsButton
onready var controls_panel_animation_player = $ControlsPanel/AnimationPlayer
onready var restart_button = $Restart
onready var undo_button = $Undo
onready var click_sound = $ClickSound

var button_tweens = {}
var menu_panel_tween: SceneTreeTween
var mute_music_button_click_sound = false

func _ready():
	if level.name == "Level00":
		steps.visible = false
		select_level_button.queue_free()
		restart_level_button.queue_free()
		restart_button.queue_free()
		undo_button.queue_free()
		menu_panel_vbox_container.margin_bottom = 160
		menu_panel.rect_size.y = 160
		menu_panel.rect_position.y = 480

	steps_animation_player.playback_speed = Global.speed

	click_sound.pitch_scale = Global.adjust_pitch(click_sound)

	if !Music.playing:
		mute_music_button.pressed = true
		mute_music_button_click_sound = true
		mute_music_button.text = "Unmute music"

	if AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")):
		mute_sounds_button.pressed = true
		mute_sounds_button.text = "Unmute sounds"

	_setup_hover(menu_button)
	_setup_hover(restart_button)
	_setup_hover(undo_button)

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

func _on_Menu_toggled(button_pressed):
	click_sound.play()

	if menu_panel_tween:
		menu_panel_tween.kill()
		menu_panel_tween = null

	menu_panel_tween = menu_panel.create_tween()
	menu_panel_tween.set_trans(Tween.TRANS_CUBIC)

	if button_pressed:
		player.can_move = false

		menu_panel_tween.set_ease(Tween.EASE_OUT)
		menu_panel_tween.tween_property(
			menu_panel,
			"rect_position:x",
			1040,
			1.0 / Global.speed
		)
	else:
		player.can_move = true

		menu_panel_tween.set_ease(Tween.EASE_IN)
		menu_panel_tween.tween_property(
			menu_panel,
			"rect_position:x",
			1280,
			1.0 / Global.speed
		)
		
		controls_button.pressed = false

func _on_SelectLevelButton_pressed():
	menu_button.pressed = false

	level.selected_level = "Level00"

	level_animation_player.play("end_level")

func _on_RestartLevelButton_pressed():
	menu_button.pressed = false

	level_animation_player.play("restart_level")

func _on_MuteMusicButton_toggled(button_pressed):
	if mute_music_button_click_sound: click_sound.play()

	if button_pressed:
		Music.stop()
		mute_music_button.text = "Unmute music"
		Global.save_config("mute_music", true)
	else:
		Music.play()
		mute_music_button.text = "Mute music"
		Global.save_config("mute_music", false)

func _on_MuteSoundsButton_toggled(button_pressed):
	click_sound.play()

	if button_pressed:
		mute_sounds_button.text = "Unmute sounds"
		Global.save_config("mute_sounds", true)
	else:
		mute_sounds_button.text = "Mute sounds"
		Global.save_config("mute_sounds", false)

	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), button_pressed)

func _on_ControlsButton_toggled(button_pressed):
	click_sound.play()

	if button_pressed:
		controls_panel_animation_player.play("show")
	else:
		controls_panel_animation_player.play_backwards("show")

func _on_Restart_pressed():
	if !player.can_move: return
	
	click_sound.play()

	level_animation_player.play("restart_level")

func _on_Undo_pressed():
	if !player.can_move: return

	click_sound.play()

	if player.tween and player.tween.is_running(): return

	level.undo()

# FinishPanel AnimationPlayer
func _on_AnimationPlayer_animation_finished(_anim_name):
	level_animation_player.play("end_level")
