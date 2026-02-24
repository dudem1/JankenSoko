extends Area2D

var tween: SceneTreeTween
var active: bool = true
onready var colliosion_shape = $CollisionShape2D
onready var animation_player = $AnimationPlayer
onready var ray = $RayCast2D
onready var level = $"../../.."

func push(dir):
	ray.cast_to = Global.inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		if !level.is_walkable_position(position + ray.cast_to): return

		tween = Global.move_tween(self, tween, dir)
		return true

	var collider = ray.get_collider()

	if collider.is_in_group("pushable") and resolve_rps(self, collider):
		collider.deactivate()
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
