extends StateMachine

@export var air_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('crouch_attack_2')

func _on_animation_finished_player_(anim_name):
	if anim_name == 'crouch_attack_2':
		next_state = air_state
