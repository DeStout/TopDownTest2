extends Node2D

var pos = Vector2.ZERO
onready var size = Vector2(get_viewport().size.x, get_viewport().size.y)
onready var rect = Rect2(pos, size)
var color = ColorN("steelblue", 1)

var debug_from_to = false
var debug_color_from = ColorN("firebrick", 1)
var debug_color_to = ColorN("chartreuse", 1)
var debug_size = Vector2(Globals.TILE_SIZE / 2, Globals.TILE_SIZE / 2)
onready var debug_from_pos
onready var debug_to_pos
onready var debug_from
onready var debug_to

var grid_texture = load("res://Assets/Images/Spacer.png")

onready var player = load("res://Scenes/Player.tscn")
onready var collect = load("res://Scenes/Collect.tscn")
onready var enemy = load("res://Scenes/Enemy.tscn")
onready var pickup = load("res://Scenes/Pickup.tscn")
onready var home = load("res://Scenes/Home.tscn")

var enemy_spawner = 0
var pickup_spawner = 0


func _ready():
	randomize()
	#spawn_home()
	create_level()
	Globals.collects = $Collects.get_child_count()
	
	if debug_from_to:
		debug_from_pos = $Player.last_position
		debug_to_pos = $Player.target_position
		debug_from = Rect2(debug_from_pos, debug_size)
		debug_to = Rect2(debug_to_pos, debug_size)


func _draw():
	draw_rect(rect, color)
	
	if debug_from_to:
		draw_rect(debug_from, debug_color_from)
		draw_rect(debug_to, debug_color_to)


func _process(delta):
	pickup_spawner += delta
	if pickup_spawner > 5:
		if randi() % 50:
			random_pickup()
	
	if $Enemies.get_child_count() < Globals.NUM_ENEMIES:
		enemy_spawner += delta
		if enemy_spawner >= 3:
			var enemy_node = enemy.instance()
			$Enemies.add_child(enemy_node)
			enemy_spawner = 0
			
	if Globals.collects == 0:
		if !has_node("Home"):
			spawn_home()
			
	if Globals.num_lives < 0:
		hard_reset()
	
	if debug_from_to:
		debug_from_pos = $Player.last_position
		debug_to_pos = $Player.target_position
		debug_from = Rect2(debug_from_pos, debug_size)
		debug_to = Rect2(debug_to_pos, debug_size)
		update()


func reset():
	Globals.save_high_score()
	Globals.create_grid_array()
	get_tree().reload_current_scene()
	
func hard_reset():
	Globals.set_high_score()
	Globals.score = 0
	Globals.num_lives = 2
	reset()


func create_level():
	set_bounds()
	create_grid()
	spawn_player()
	spawn_enemies()
	spawn_collects()
	spawn_pickups()
	
	for temp_enemy in $Enemies.get_children():
		var temp_pos = temp_enemy.last_position
		Globals.collect_grid[temp_pos.x][temp_pos.y] = 0
		
	$GUI.rect_global_position.y = Globals.viewport.y - 64


func set_bounds():
	for shape in $BoundsCollision.get_children():
		match shape.name:
			"Top":
				shape.position = Vector2((Globals.grid_size.x * 2 + 1) * Globals.TILE_SIZE / 4, -Globals.TILE_SIZE / 4)
				shape.shape.extents = Vector2((Globals.grid_size.x * 2 + 1) * 16, 16)
			"Right":
				shape.position = Vector2((Globals.grid_size.x * 2 + 1) * Globals.TILE_SIZE / 2 + Globals.TILE_SIZE / 4, (Globals.grid_size.y * 2 + 1) * Globals.TILE_SIZE / 4)
				shape.shape.extents = Vector2(16, (Globals.grid_size.y * 2 + 1) * 16)
			"Bottom":
				shape.position = Vector2((Globals.grid_size.x * 2 + 1) * Globals.TILE_SIZE / 4, (Globals.grid_size.y * 2 + 1) * Globals.TILE_SIZE / 2 + Globals.TILE_SIZE / 4)
				shape.shape.extents = Vector2((Globals.grid_size.x * 2 + 1) * 16, 16)
			"Left":
				shape.position = Vector2(-Globals.TILE_SIZE / 4, (Globals.grid_size.y * 2 + 1) * Globals.TILE_SIZE / 4)
				shape.shape.extents = Vector2(16, (Globals.grid_size.y * 2 + 1) * 16)


func create_grid():
	var grid_node = get_node("Grid")
	for x in range(Globals.grid_size.x + 1):
		for y in range(Globals.grid_size.y + 1):
			var grid = Sprite.new()
			grid.centered = false
			grid.set_texture(grid_texture)
			grid.position = Vector2(x * Globals.TILE_SIZE, y * Globals.TILE_SIZE)
			grid_node.add_child(grid)


func spawn_player():
	var player_node = player.instance()
	player_node.position = Vector2(Globals.TILE_SIZE * 1.5, Globals.TILE_SIZE / 2)
	Globals.collect_grid[1][0] = 1
	add_child(player_node)


func spawn_enemies():
	for i in range(Globals.NUM_ENEMIES):
		var enemy_node = enemy.instance()
		$Enemies.add_child(enemy_node)


func spawn_collects():
	for x in range(Globals.grid_size.x):
		for y in range(Globals.grid_size.y):
			var collect_node = collect.instance()
			collect_node.position = Vector2(Globals.TILE_SIZE * x + Globals.TILE_SIZE / 2, Globals.TILE_SIZE * y + Globals.TILE_SIZE / 2)
			collect_node.grid_location = Vector2(x, y)
			if !(x == 1 && y == 0) && Globals.collect_grid[x][y] != 1:
				if randi() % 10:
					$Collects.add_child(collect_node)
					Globals.collect_grid[x][y] = 1


func spawn_pickups():
	for x in range(Globals.grid_size.x):
		for y in range(Globals.grid_size.y):
			if Globals.collect_grid[x][y] == 0:
				var pickup_node = pickup.instance()
				pickup_node.position = Vector2(Globals.TILE_SIZE * x + Globals.TILE_SIZE / 2, Globals.TILE_SIZE * y + Globals.TILE_SIZE / 2)
				pickup_node.grid_location = Vector2(x, y)
				$Pickups.add_child(pickup_node)
				Globals.collect_grid[x][y] = 1


func random_pickup():
	var x = randi() % int(Globals.grid_size.x)
	var y = randi() % int(Globals.grid_size.y)
	if Globals.collect_grid[x][y] == 0:
		var pickup_node = pickup.instance()
		pickup_node.position = 	Vector2(Globals.TILE_SIZE * x + Globals.TILE_SIZE / 2, Globals.TILE_SIZE * y + Globals.TILE_SIZE / 2)
		pickup_node.grid_location = Vector2(x, y)
		$Pickups.add_child(pickup_node)
		Globals.collect_grid[x][y] = 1
		pickup_spawner = 0


func spawn_home():
	var home_node = home.instance()
	var home_position
	var home_rotation = 0
	var border_position = randi() % (int(Globals.grid_size.x) * 2 + int(Globals.grid_size.y) * 2)
	
	if border_position < Globals.grid_size.x:
		home_position = Vector2(border_position, 0)
		home_position.x = home_position.x * Globals.TILE_SIZE + Globals.TILE_SIZE / 2
	elif border_position < Globals.grid_size.x + Globals.grid_size.y:
		home_position = Vector2(Globals.viewport.x, border_position - Globals.grid_size.x)
		home_position.y = home_position.y * Globals.TILE_SIZE + Globals.TILE_SIZE / 2
		home_rotation = PI / 2
	elif border_position < Globals.grid_size.x * 2 + Globals.grid_size.y:
		home_position = Vector2(border_position - Globals.grid_size.x - Globals.grid_size.y, Globals.viewport.y)
		home_position.x = home_position.x * Globals.TILE_SIZE + Globals.TILE_SIZE / 2
		home_position.y -= (Globals.TILE_SIZE / 2 + 64)
	else:
		home_position = Vector2(0, border_position - (Globals.grid_size.x * 2) - Globals.grid_size.y)
		home_position.y = home_position.y * Globals.TILE_SIZE + Globals.TILE_SIZE
		home_rotation = -PI / 2
	
	home_node.position = home_position
	home_node.rotation = home_rotation
	add_child(home_node)
