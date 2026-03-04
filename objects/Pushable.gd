extends Area2D

var tween: SceneTreeTween
var active: bool = true
var destroy_sound := AudioStreamPlayer.new()
onready var colliosion_shape = $CollisionShape2D
onready var animation_player = $AnimationPlayer
onready var ray = $RayCast2D
onready var level = $"../../.."

func _ready():
	animation_player.playback_speed = Global.speed

	destroy_sound.stream = preload("res://assets/sounds/destroy.mp3")
	destroy_sound.bus = "SFX"
	destroy_sound.pitch_scale = Global.adjust_pitch(destroy_sound)
	add_child(destroy_sound)

func push(dir):
	ray.cast_to = Global.inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		if !level.is_walkable_position(position + ray.cast_to): return

		level.save_state()
		tween = Global.move_tween(self, tween, dir)
		return true

	var collider = ray.get_collider()

	if collider.is_in_group("pushable") and resolve_rps(self, collider):
		level.save_state()
		collider.deactivate()
		destroy_sound.play()
		tween = Global.move_tween(self, tween, dir)
		return true

	return false

func activate():
	active = true
	animation_player.play_backwards("poof")
	colliosion_shape.set_deferred("disabled", false)

func deactivate():
	active = false
	animation_player.play("poof")
	colliosion_shape.set_deferred("disabled", true)

# Returns true if attacker defeats defender by rock-paper-scissors rules.
func resolve_rps(attacker, defender) -> bool:
	var beats = {
		"rock": "scissors",
		"scissors": "paper",
		"paper": "rock"
	}

	for key in beats.keys():
		if attacker.is_in_group(key) and defender.is_in_group(beats[key]):
			return true

	return false
