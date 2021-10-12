extends StateMachine


func _ready():
	add_state("Idle")
	add_state("Walk")
	add_state("Turn")
	add_state("Attack")
	call_deferred("set_state", states.Idle)


func _state_logic(delta):
	if [states.Idle, states.Walk].has(state):
		parent.update_movement()
		parent.move(delta)
	elif state == states.Turn:
		pass
	elif state == states.Attack:
		pass
	
	parent.get_input()
	parent.check_collisions()


func _get_transition(delta):
	match state:
		states.Idle:
			if parent.input != Vector2.ZERO:
				return states.Walk
			if parent.should_attack():
				return states.Attack
		states.Walk:
			if parent.movement == Vector2.ZERO:
				parent.reset_positions()
				return states.Idle
			if parent.should_turn():
				return states.Turn
			if parent.should_attack():
				return states.Attack
		states.Turn:
			if !parent.finished_turning():
				return states.Walk
		states.Attack:
			if parent.should_attack():
				parent.start_attack()
			if !parent.finished_attacking():
				if parent.movement == Vector2.ZERO:
					return states.Idle
				elif parent.movement != Vector2.ZERO:
					return states.Walk


func _enter_state(new_state, old_state):
	match new_state:
		states.Idle:
			parent.get_node("Animator").play("Idle")
		states.Walk:
			parent.set_animation()
		states.Turn:
			parent.turn_around()
		states.Attack:
			parent.start_attack()


func _exit_state(old_state, new_state):
	pass
