extends Node

var tile_size = 80
var inputs = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
}
var speed = 7

func _ready():
	OS.set_window_position(Vector2(200, 50))

func move_tween(node: Node2D, tween: SceneTreeTween, dir) -> SceneTreeTween:
	if tween:
		tween.kill()
		tween = null

	tween = node.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		node,
		"position",
		node.position + inputs[dir] * tile_size,
		1.0 / speed
	)

	return tween
