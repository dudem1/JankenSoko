extends Area2D

var tween: SceneTreeTween
onready var ray = $RayCast2D
onready var level = $"../.."

func _unhandled_input(event):
	if tween and tween.is_running(): return

	for dir in Global.inputs.keys():
		if event.is_action_pressed(dir):
			move(dir)

func move(dir):
	ray.cast_to = Global.inputs[dir] * Global.tile_size
	ray.force_raycast_update()

	level.save_state()

	if !ray.is_colliding():
		tween = Global.move_tween(self, tween, dir)
		return

	var collider = ray.get_collider()

	if collider.is_in_group("pushable"):
		if collider.push(dir):
			tween = Global.move_tween(self, tween, dir)
		return
