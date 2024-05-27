extends StateMachine


@export var ground_state:StateMachine
@export var doble_jump_state:StateMachine
@export var attack_state:StateMachine

var _double_jump_charged =false

func _on_enter():
	WALK_SPEED = 600.0
	#animationPlayer.play('jumping')
	pass # Replace with function body.


func _on_animation_finished_player_(anim_name):
	print('animation_finished enter:', next_state)
	#next_state = ground_state
	
func state_process(delta):
	if character.is_on_floor():
		next_state = ground_state
	if character.velocity.y<0:
		#animationPlayer.play('jumping')
		pass
	if character.velocity.y>0:
		animationPlayer.play('falling')
		
func state_input(event:InputEvent):
	if event.is_action_pressed("jump" +  character.action_suffix) and _double_jump_charged :
			# The player let go of jump early, reduce vertical momentum.
		_double_jump_charged = false		
		animationPlayer.play('jumping')
		character.velocity.x *= 2.5
		character.jump_sound.pitch_scale = 4
		character.velocity.y = JUMP_VELOCITY/1.1
		character.jump_sound.play()
		next_state=doble_jump_state
	elif event.is_action_pressed("shoot" +  character.action_suffix):
		next_state=attack_state


func _on_exit():
	_double_jump_charged=false
