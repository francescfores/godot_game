extends StateMachine

 
@export var ground_state:StateMachine
@export var doble_jump_state:StateMachine
@export var attack_state:StateMachine
@export var jump_attack_down_1_state:StateMachine
@export var jump_wall_state:StateMachine
@export var jump_hang_state:StateMachine
@export var climb_state:StateMachine

var _double_jump_charged =false	

func _on_enter():
	WALK_SPEED = 300.0
	can_climb=false
	character.gravity = ProjectSettings.get("physics/2d/default_gravity")
	#animationPlayer.play('jumping')
	pass # Replace with function body.


func _on_animation_finished_player_(anim_name):
	print('animation_finished enter:', next_state)
	#next_state = ground_state
	
func state_process(delta):
	if character.is_on_floor():
		next_state = ground_state
	if character.velocity.y<0:
		animationPlayer.play('jumping')
		pass
	if character.velocity.y>0:
		animationPlayer.play('falling')

	if character.is_on_wall():	
		jump_wall_state.speed=character.direction
		next_state = jump_wall_state
		
func state_input(event:InputEvent):
	print('state air ', can_hang)
	if !can_hang and event.is_action_pressed("jump" +  character.action_suffix) and _double_jump_charged :
			# The player let go of jump early, reduce vertical momentum.
		_double_jump_charged = false		
		animationPlayer.play('jumping')
		#character.velocity.x *= 1.2
		character.jump_sound.pitch_scale = 4
		character.velocity.y = JUMP_VELOCITY
		character.jump_sound.play()
		next_state=doble_jump_state

	if  event.is_action_pressed('move_down'+  character.action_suffix):
		next_state=jump_attack_down_1_state
	if event.is_action_pressed("shoot" +  character.action_suffix):

		next_state=attack_state
	if can_hang and event.is_action_pressed("ui_up"):	
		jump_hang_state.hang_position=hang_position
		next_state=jump_hang_state
	if can_climb and event.is_action_pressed("ui_up"):
		print(climb_position)	
		climb_state.climb_position=climb_position
		next_state=climb_state
func _on_exit():
	_double_jump_charged=false
