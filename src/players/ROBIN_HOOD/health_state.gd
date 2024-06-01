extends StateMachine

@export var air_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('health')

func _on_animation_finished_player_(anim_name):
	if anim_name == 'health':
		next_state = air_state
