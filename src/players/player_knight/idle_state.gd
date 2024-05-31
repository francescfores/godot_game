extends StateMachine


@export var jump_state:StateMachine
@export var attack_state:StateMachine
@export var pray_state:StateMachine
@export var crouch_state:StateMachine
@export var slide_state:StateMachine
@export var coyote_timer:Timer
@export var climb_state:StateMachine
@export var roll_state:StateMachine
@export var health_state:StateMachine
@export var dash_state:StateMachine
func _on_enter():
	print('State sssssssssssenter:', self.name)
	can_climb=false
	pass # Replace with function body.

func state_process(delta):
	#if character.is_on_floor():
	#	_double_jump_charged = true
	if !character.is_on_floor():
		if coyote_timer.is_stopped():
			coyote_timer.start()
	if character.velocity.x!=0:
		animationPlayer.play('run')
	else:
		animationPlayer.play('idle')
	pass
	
func _on_animation_finished_player_(anim_name):
	print('idle animation_finished enter:', next_state)
	#next_state = jump_state


func state_input(event:InputEvent):
		#pray
	if event.is_action_pressed("pray" + character.action_suffix):
		next_state=pray_state
	if event.is_action_pressed("move_down" + character.action_suffix):
		next_state=crouch_state	
		#todo create and change state pray
	#character.velocity.y = 0.6
	if !can_climb and event.is_action_pressed("jump" +  character.action_suffix):
		print('idle animation_finished enter:', next_state)
		animationPlayer.play('jumping')
		jump_state._double_jump_charged = true
		try_jump()
	elif event.is_action_released("jump" +  character.action_suffix) and character.velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		character.velocity.y *= 0.6
	if event.is_action_pressed('move_down'+  character.action_suffix) and abs(character.velocity.x) > 0.0:
		character.velocity.x = character.velocity.x*2.5
		slide_state.speed = character.velocity.x
		next_state=slide_state
	if event.is_action_pressed('roll'+  character.action_suffix):
		character.velocity.x = character.velocity.x*2.5
		slide_state.speed = character.velocity.x
		next_state=roll_state
	if event.is_action_pressed("shoot" +  character.action_suffix):
		next_state=attack_state
		
	if event.is_action_pressed("health"):
		print('health')	
		next_state=health_state
	if event.is_action_pressed("dash"):
		print('health')	
		character.velocity.x = dash_state.WALK_SPEED*4 * character.direction
		dash_state.speed = character.velocity.x
		next_state=dash_state
	#elif event.is_action_released("jump" +  character.action_suffix) and character.velocity.y < 0.0:
			# The player let go of jump early, reduce vertical momentum.
	#	character.velocity.y *= 0.6
func try_jump() -> void:
	if character.is_on_floor():
		#print('is_on_floor jump')
		character.jump_sound.pitch_scale = 1.0
	#else:
	#	return
	character.velocity.y = JUMP_VELOCITY
	character.jump_sound.play()
	next_state=jump_state


func _on_coyote_timer_timeout():
		next_state=jump_state
