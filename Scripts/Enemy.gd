extends Node2D

onready var anim_player = $Sprite

var speed = 60

var last_position = Vector2()
var target_position = Vector2()
var movement = Vector2()

var stall_timer = Timer
var stunned = false
var times_attacked = 0


func _ready():
	last_position = random_position()
	position.x = last_position.x * Globals.TILE_SIZE + 32
	position.y = last_position.y * Globals.TILE_SIZE + 32
	target_position = last_position
	
	stall_timer = Timer.new()
	stall_timer.set_one_shot(true)
	add_child(stall_timer)


#func _process(delta):
#	var areas = $Area.get_overlapping_areas()
#	for area in areas:
#		if area.name == "PlayerCollision":
#			Globals.num_lives -= 1
#			area.get_parent().send_home()


func random_position():
	var temp_vector = Vector2()
	temp_vector.x = randi() % int(Globals.grid_size.x)
	temp_vector.y = randi() % int(Globals.grid_size.y)
	
	while (temp_vector.x <= 2 && temp_vector.y <= 2) || Globals.collect_grid[temp_vector.x][temp_vector.y] == 1:
		temp_vector.x = randi() % int(Globals.grid_size.x)
		temp_vector.y = randi() % int(Globals.grid_size.y)
	Globals.collect_grid[temp_vector.x][temp_vector.y] = 1
	return temp_vector


func random_movement():
	return Vector2(randi() % 3 - 1, randi() % 3 - 1)


func validify_and_set_target(var temp_movement):
	if temp_movement.x != 0 and temp_movement.y != 0:
		return false
	elif temp_movement.x == 0 and temp_movement.y == 0:
		return false
	elif last_position.x + 1 == Globals.grid_size.x and temp_movement.x == 1:
		temp_movement.x *= -1
	elif last_position.x == 0 and temp_movement.x == -1:
		temp_movement.x *= -1
	elif last_position.y + 1 == Globals.grid_size.y and temp_movement.y == 1:
		temp_movement.y *= -1
	elif last_position.y == 0 and temp_movement.y == -1:
		temp_movement.y *= -1
	
	set_target(temp_movement)
	return true


func set_target(var temp_movement):
	movement = temp_movement
	
	target_position = Vector2.ZERO
	
	if abs(movement.x):
		if movement.x < 0:
			target_position.x = -(randi() % int(last_position.x) + 1)
		else:
			target_position.x = (randi() % int(Globals.grid_size.x - last_position.x - 1) + 1)
	else:
		if movement.y < 0:
			target_position.y = -(randi() % int(last_position.y) + 1)
		else:
			target_position.y = (randi() % int(Globals.grid_size.y - last_position.y - 1) + 1)
	
	target_position.x += last_position.x
	target_position.y += last_position.y


func move(delta):
	var real_last_position = Vector2(last_position.x*Globals.TILE_SIZE+32, last_position.y*Globals.TILE_SIZE+32)
	position += movement * speed * delta
	
	if position.distance_to(real_last_position) > last_position.distance_to(target_position) * Globals.TILE_SIZE:
		position.x = target_position.x * Globals.TILE_SIZE + 32
		position.y = target_position.y * Globals.TILE_SIZE + 32
		last_position = target_position


func reached_target():
	return last_position == target_position


func attacked():
	stunned = true
	stall_timer.set_wait_time(0.4)
	stall_timer.connect("timeout", self, "end_stunned")
	stall_timer.start()


func is_stunned():
	return stunned


func end_stunned():
	times_attacked = 0
	stunned = false


func is_dead():
	return times_attacked >= 2


func died():
	Globals.score += 500
	movement = get_parent().get_parent().get_node("Player").movement


func die(delta):
	position += movement * 2000 * delta


func _on_OnScreen_viewport_exited(viewport):
	queue_free()


func _area_entered(area):
	pass
