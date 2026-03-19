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
	"Level02": {"gold": 1, "silver": 2},
	"Level03": {"gold": 1, "silver": 2},
	"Level04": {"gold": 1, "silver": 2},
	"Level05": {"gold": 1, "silver": 2},
	"Level06": {"gold": 1, "silver": 2},
	"Level07": {"gold": 1, "silver": 2},
	"Level08": {"gold": 1, "silver": 2},
	"Level09": {"gold": 1, "silver": 2},
	"Level10": {"gold": 1, "silver": 2},
	"Level11": {"gold": 1, "silver": 2}
}
var player_steps = {}
const SAVE_FILE = "user://player_steps.save"

var play_intro_animation = true

func _ready():
	OS.set_window_position(Vector2(200, 50))

	load_steps()

func load_steps():
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)

	if err == OK:
		for level_name in LEVEL_TROPHY_REQUIREMENTS.keys():
			player_steps[level_name] = config.get_value("steps", level_name, 0)
	else:
		for level_name in LEVEL_TROPHY_REQUIREMENTS.keys():
			player_steps[level_name] = 0

func save_steps(level_name: String, steps: int) -> void:
	if player_steps.has(level_name) and steps >= player_steps[level_name] and player_steps[level_name] != 0:
		return

	player_steps[level_name] = steps

	var config = ConfigFile.new()
	for lname in player_steps.keys():
		config.set_value("steps", lname, player_steps[lname])

	var err = config.save(SAVE_FILE)
	if err != OK: print("Error: ", err)

func set_trophy(level_name: String) -> Color:
	var steps = player_steps.get(level_name, 0)

	if steps == 0: return Color(255, 255, 255) 

	var req = LEVEL_TROPHY_REQUIREMENTS[level_name]

	if steps <= req.gold: return Color("#FFD700")
	elif steps <= req.silver: return Color("#C0C0C0")
	else: return Color("#CD7F32")
	 

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
