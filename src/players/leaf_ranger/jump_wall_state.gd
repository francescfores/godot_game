extends StateMachine

@export var air_state : StateMachine
@export var jump_wall_state : StateMachine
var speed
@export var wall_slide_gravity = 100
@export var wall_push_back = 200

func _on_enter():
	animationPlayer.play('hanging')
	print('epaaaaaaaaaaaaa character.direction', character.direction)
	character.velocity.y=0
	character.gravity=0
#	character.sprite.offset.x=4*character.direction
func state_process(delta):
	if !character.is_on_wall():
		character.sprite.offset.x=0
		next_state = air_state
		character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		
	pass
func state_input(event:InputEvent):	
	if event.is_action_pressed("jump" + character.action_suffix):
		print('State dddddddddddddddddddspeed:', speed)
		character.sprite.offset.x=0
		character.velocity.x = (2*JUMP_VELOCITY)*speed
		character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		character.velocity.y = JUMP_VELOCITY*0.8
	
func _on_animation_finished_player_(anim_name):
	if anim_name == 'hanging':
		character.sprite.offset.x=0
		next_state = air_state
		character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		pass
	
