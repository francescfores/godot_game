extends StateMachine

@export var ground_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('slide')

	
func state_process(delta):
	if character.velocity.x==0:
		next_state = ground_state
		
func _on_animation_finished_player_(anim_name):
	if anim_name == 'slide':
		next_state = ground_state
	
