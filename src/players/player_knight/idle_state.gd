extends StateMachine


@export var jump_state:StateMachine
@export var attack_state:StateMachine
@export var coyote_timer:Timer

func _on_enter():
	print('State sssssssssssenter:', self.name)
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
	
	#character.velocity.y = 0.6
	if event.is_action_pressed("jump" +  character.action_suffix):
		print('idle animation_finished enter:', next_state)
		animationPlayer.play('jumping')
		jump_state._double_jump_charged = true
		try_jump()
	elif event.is_action_pressed("shoot" +  character.action_suffix):
		next_state=attack_state
		
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
