extends Node2D

var up_texture = load("res://Assets/Images/Fast.png")
var down_texture = load("res://Assets/Images/Slow.png")

var grid_location = Vector2.ZERO

var despawn = 0
var despawn_timer = 0
var type = null
var PICKUPS = {"Up": 0, "Down": 1}


func _ready():
	despawn = randi() % 5 + 10
	match randi() % 2:
		0:
			type = PICKUPS.Up
			$Sprite.set_texture(up_texture)
		1:
			type = PICKUPS.Down
			$Sprite.set_texture(down_texture)


func _process(delta):
	despawn_timer += delta
	if despawn_timer >= despawn:
		despawn()


func despawn():
	Globals.collect_grid[grid_location.x][grid_location.y] = 0
	queue_free()
