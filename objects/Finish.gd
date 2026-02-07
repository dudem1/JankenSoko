extends Area2D

func _ready():
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area):
	if area.is_in_group("player"):
		print("game over")
