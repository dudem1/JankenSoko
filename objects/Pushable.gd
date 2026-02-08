extends Area2D

var tween: SceneTreeTween
onready var ray = $RayCast2D

func push(dir):
	ray.cast_to = Global.inputs[dir] * Global.tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		tween = Global.move_tween(self, tween, dir)
		return true

	var collider = ray.get_collider()

	if collider.is_in_group("pushable") and resolve_rps(self, collider):
		collider.deactivate()
		tween = Global.move_tween(self, tween, dir)
		return true

	return false

func activate():
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)

func deactivate():
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)

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
