extends StateMachine

@export var spawn_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('death')

func _on_animation_finished_player_(anim_name):
	if anim_name == 'death':
		next_state = spawn_state
	
