extends Node2D

func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().get_name() == "Player":
		if Globals.num_lives < 2:
			Globals.num_lives += 1
		Globals.score += 10000
		get_parent().reset()

func _on_Blink_timeout():
	visible = !visible
