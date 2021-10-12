extends Node2D

const MAX_SPEED = 120
const MIN_SPEED = 60

var stall_timer = Timer
var speed = (MAX_SPEED + MIN_SPEED) / 2
var movement = Vector2.ZERO
var temp_movement = movement
var input = Vector2.ZERO

var last_position = Vector2()
var target_position = Vector2()

var turning = false
var attacking = false

onready var ray = $RayCast2D

func _ready():
	#position = position.snapped(Vector2(Globals.TILE_SIZE, Globals.TILE_SIZE))
	#position = Vector2(position.x + 32, position.y + 32)
	ray.add_exception($Area2D)
	
	stall_timer = Timer.new()
	stall_timer.set_one_shot(true)
	add_child(stall_timer)
	
	reset_positions()


func reset_positions():
	last_position = position
	target_position = position


func get_input():
	input.x = int(Input.is_action_pressed("Move_Right")) - int(Input.is_action_pressed("Move_Left"))
	input.y = int(Input.is_action_pressed("Move_Down")) - int(Input.is_action_pressed("Move_Up"))
	if input.x != 0 and input.y != 0:
		input = Vector2.ZERO


func update_movement():
	if position == target_position:
		set_movement()
		last_position = position
		target_position.x += movement.x * Globals.TILE_SIZE
		target_position.y += movement.y * Globals.TILE_SIZE


func set_movement():
	if input != Vector2.ZERO:
		movement = input
		ray.cast_to = movement * Globals.TILE_SIZE / 3
		set_animation()


func check_collisions():
	var colliding_object = ray.get_collider()
	if colliding_object != null:
		if colliding_object.name == "Bounds":
			pass
			
		if colliding_object.name == "EnemyCollision":
			var temp_enemy = colliding_object.get_parent()
			if attacking:
				temp_enemy.attacked()
				if Input.is_action_just_pressed("Attack"):
					temp_enemy.times_attacked += 1


func move(delta):
	position += movement * speed * delta
		
	if position.distance_to(last_position) >= Globals.TILE_SIZE - (speed * delta):
		position = target_position


func set_animation():
	match movement:
		Vector2(0, -1):
			$Animator.play("Walk_Up")
		Vector2(0, 1):
			$Animator.play("Walk_Down")
		Vector2(1, 0):
			$Animator.flip_h = true
			$Animator.play("Walk_Side")
		Vector2(-1, 0):
			$Animator.flip_h = false
			$Animator.play("Walk_Side")


func should_turn():
	if movement == input * -1:
		return true


func turn_around():
	turning = true
	stall_timer.set_wait_time(0.1)
	stall_timer.connect("timeout", self, "end_turning")
	stall_timer.start()
	temp_movement = input
	ray.cast_to = temp_movement * Globals.TILE_SIZE / 4
	turned_update_target()


func turned_update_target():
	var temp = target_position
	target_position = last_position
	last_position = temp


func end_turning():
	turning = false
	movement = temp_movement
	#temp_movement = Vector2.ZERO


func finished_turning():
	return turning


func should_attack():
	return Input.is_action_just_pressed("Attack")


func start_attack():
	attacking = true
	temp_movement = movement
	stall_timer.set_wait_time(0.22)
	stall_timer.connect("timeout", self, "end_attack")
	
	if $Animator.animation == "Punch_Side":
		$Animator.frame = 0
	$Animator.play("Punch_Side")
	var attack_sfx = get_node("Attack" + str(randi()%3+1))
	attack_sfx.play()
	
	stall_timer.start()


func end_attack():
	attacking = false
	movement = temp_movement
	#temp_movement = Vector2.ZERO


func finished_attacking():
	return attacking


func change_speed(var delta):
	if (delta > 0 and speed < MAX_SPEED) or (delta < 0 and speed > MIN_SPEED):
		speed += delta


func send_home():
	position = Vector2(Globals.TILE_SIZE * 1.5, Globals.TILE_SIZE / 2)
	movement = Vector2.ZERO
	speed = (MAX_SPEED + MIN_SPEED) / 2
	reset_positions()


func _area_entered(area):
	match area.name:
		"CollectCollision":
			var collect = area.get_parent()
			Globals.score += 100
			Globals.set_high_score()
			collect.despawn()
		"PickupCollision":
			var pickup = area.get_parent()
			match pickup.type:
				pickup.PICKUPS.Up:
					change_speed(10)
				pickup.PICKUPS.Down:
					change_speed(-10)
			pickup.despawn()
		"EnemyCollision":
			Globals.num_lives -= 1
			send_home()
		"BoundsCollision":
			position = last_position
			target_position = position
			movement = Vector2.ZERO
			Globals.num_lives -= 1
