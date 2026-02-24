extends Area2D

var tween: SceneTreeTween
var can_move: bool = false
onready var ray = $RayCast2D
onready var animation_player = $AnimationPlayer
onready var level = $"../../.."

# swipe
var swipe_start = null
var minimum_drag = Global.tile_size * 0.3

func _ready():
	animation_player.playback_speed = Global.speed

func _unhandled_input(event):
	if !can_move: return

	if tween and tween.is_running(): return

	# keyboard
	for dir in Global.inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

	# swipe
	if event is InputEventScreenTouch:
		if event.pressed:
			swipe_start = event.position
		else:
			if swipe_start != null:
				calculate_swipe(event.position)
				swipe_start = null

func move(dir):
	ray.cast_to = Global.inputs[dir] * Global.tile_size
	ray.force_raycast_update()

	level.save_state()

	if !ray.is_colliding():
		if !level.is_walkable_position(position + ray.cast_to): return

		tween = Global.move_tween(self, tween, dir)
		animation_player.play("move")
		level.change_step(1)
		return

	var collider = ray.get_collider()

	if collider.is_in_group("pushable"):
		if collider.push(dir):
			tween = Global.move_tween(self, tween, dir)
			animation_player.play("move")
			level.change_step(1)
		return

func calculate_swipe(swipe_end: Vector2):
	if swipe_start == null: return

	var swipe = swipe_end - swipe_start

	if swipe.length() < minimum_drag: return

	if abs(swipe.x) > abs(swipe.y):
		if swipe.x > 0:
			move("ui_right")
		else:
			move("ui_left")
	else:
		if swipe.y > 0:
			move("ui_down")
		else:
			move("ui_up")
