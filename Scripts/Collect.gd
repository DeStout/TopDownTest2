extends Node2D

var grid_location = Vector2.ZERO


func despawn():
	Globals.collect_grid[grid_location.x][grid_location.y] = 0
	Globals.collects -= 1
	queue_free()
