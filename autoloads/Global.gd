extends Node

var tile_size = 80
var inputs = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}
var speed = 7

const LEVEL_TROPHY_REQUIREMENTS = {
	"Level01": {"gold": 33, "silver": 35},
	"Level02": {"gold": 13, "silver": 17},
	"Level03": {"gold": 43, "silver": 47},
	"Level04": {"gold": 24, "silver": 25},
	"Level05": {"gold": 28, "silver": 32},
	"Level06": {"gold": 102, "silver": 108},
	"Level07": {"gold": 23, "silver": 29},
	"Level08": {"gold": 56, "silver": 60},
	"Level09": {"gold": 158, "silver": 164},
	"Level10": {"gold": 115, "silver": 125},
	"Level11": {"gold": 19, "silver": 36}
}
var player_steps = {}
const CONFIG_FILE = "user://config.cfg"

var play_intro_animation = true
var back_from_level = "Level00"

func _ready():
	OS.set_window_position(Vector2(200, 50))

	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)

	if err == OK:
		for level_name in LEVEL_TROPHY_REQUIREMENTS.keys():
			player_steps[level_name] = config.get_value("steps", level_name, 0)

		Music.playing = !config.get_value("config", "mute_music", 0)

		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), config.get_value("config", "mute_sounds", 0))
	else:
		for level_name in LEVEL_TROPHY_REQUIREMENTS.keys():
			player_steps[level_name] = 0
		
		Music.play()

func save_steps(level_name: String, steps: int) -> void:
	if player_steps.has(level_name) and steps >= player_steps[level_name] and player_steps[level_name] != 0:
		return

	player_steps[level_name] = steps

	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	for lname in player_steps.keys():
		config.set_value("steps", lname, player_steps[lname])

	var err = config.save(CONFIG_FILE)
	if err != OK: print("Error: ", err)

func save_config(parameter, value):
	var config = ConfigFile.new()
	config.load(CONFIG_FILE)
	config.set_value("config", parameter, value)

	var err = config.save(CONFIG_FILE)
	if err != OK: print("Error: ", err)

func set_trophy(level_name: String, steps: int) -> Color:
	if steps == 0: return Color(255, 255, 255) 

	var req = LEVEL_TROPHY_REQUIREMENTS[level_name]

	if steps <= req.gold: return Color("#FFD700")
	elif steps <= req.silver: return Color("#C0C0C0")
	else: return Color("#CD7F32")

func get_steps_to_next_trophy(level_name: String, steps: int) -> String:
	var req = LEVEL_TROPHY_REQUIREMENTS[level_name]

	if steps <= req.gold:
		return "Gold achieved!🥇"

	var diff
	var target

	if steps <= req.silver:
		diff = steps - req.gold
		target = "gold"
	else:
		diff = steps - req.silver
		target = "silver"

	var step_word = "step" if diff == 1 else "steps"

	return str(diff) + " " + step_word + " away from " + target + "!"

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and !event.echo:
		if event.scancode == KEY_ESCAPE:
			get_tree().quit()

func move_tween(node: Node2D, tween: SceneTreeTween, dir) -> SceneTreeTween:
	if tween:
		tween.kill()
		tween = null

	tween = node.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		node,
		"position",
		node.position + inputs[dir] * tile_size,
		1.0 / speed
	)

	return tween

func adjust_pitch(audio: AudioStreamPlayer) -> float:
	return clamp(audio.stream.get_length() * speed, 0.1, 20.0)
