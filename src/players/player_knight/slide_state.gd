extends StateMachine

@export var ground_state : StateMachine
var speed
func _on_enter():
	animationPlayer.play('slide')
	print('State sssssssssssenter:', self.name)
	print('State speed:', speed)

func state_process(delta):
	print('State character.velocity.x:', character.velocity.x)
	if abs(character.velocity.x)<=100:
		next_state = ground_state
	character.velocity.x = move_toward(character.velocity.x, speed,ACCELERATION_SPEED * delta)
	speed=character.velocity.x/1.02
	print('State character.velocity.x:', character.velocity.x)

func _on_animation_finished_player_(anim_name):
	if anim_name == 'slide':
		#next_state = ground_state
		pass
	
