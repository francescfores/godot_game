extends StateMachine

@export var air_state : StateMachine
@export var jump_wall_state : StateMachine
var speed
@export var wall_slide_gravity = 100
@export var wall_push_back = 200

func _on_exit():
	character.sprite.offset.x=0
	character.sprite.offset.y=0
	next_state = air_state
	
func _on_enter():
	animationPlayer.play('hanging')
	character.velocity.y=0
	character.gravity=0
	if hang_position.x > character.global_position.x:
		character.velocity.x=100
		character.sprite.offset.x=-2
		character.sprite.offset.y=25
	else:
		character.velocity.x=-100
		character.sprite.offset.x=2
		character.sprite.offset.y=25
		
	character.global_position=hang_position
		
	#character.sprite.offset.x=4*speed
func state_process(delta):
	print('hang')
	print(can_hang)
	
	#if !character.is_on_wall():
	#	next_state = air_state
	#	character.sprite.offset.x=0
	#	character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		
	pass
func state_input(event:InputEvent):	
	if event.is_action_pressed("jump" + character.action_suffix):
		print('State dddddddddddddddddddspeed:', speed)
		character.sprite.offset.x=0
		#character.velocity.x = (2*JUMP_VELOCITY)*speed
		character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		character.velocity.y = JUMP_VELOCITY*0.8
		character.sprite.offset.y=0
		character.sprite.offset.x=0
		next_state = air_state
	
func _on_animation_finished_player_(anim_name):
	if anim_name == 'hanging':
		#character.sprite.offset.x=0
		#next_state = air_state
		#character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		pass
	
