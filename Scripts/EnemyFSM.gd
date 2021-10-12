extends StateMachine


func _ready():
	add_state("Idle")
	add_state("Walk")
	add_state("Attack")
	add_state("Stunned")
	add_state("Dead")
	call_deferred("set_state", states.Idle)


func _state_logic(delta):
	match(state):
		states.Idle:
			pass
		states.Walk:
			parent.move(delta)
		states.Attack:
			pass
		states.Stunned:
			pass
		states.Dead:
			parent.die(delta)


func _get_transition(delta):
	match(state):
		states.Idle:
			if parent.validify_and_set_target(parent.random_movement()):
				return states.Walk
			if parent.is_stunned():
				return states.Stunned
		states.Walk:
			if parent.reached_target():
				return states.Idle
			if parent.is_stunned():
				return states.Stunned
		states.Attack:
			pass
		states.Stunned:
			if !parent.is_stunned():
				return states.Walk
			if parent.is_dead():
				return states.Dead


func _enter_state(new_state, old_state):
	match new_state:
		states.Idle:
			pass
		states.Walk:
			pass
		states.Attack:
			pass
		states.Stunned:
			pass
		states.Dead:
			parent.died()


func _exit_state(old_state, new_state):
	pass
