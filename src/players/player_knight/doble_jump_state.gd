extends StateMachine

@export var ground_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('idle_attack_1')

func _on_animation_finished_player_(anim_name):
	if anim_name == 'idle_attack_1':
		next_state = ground_state
	
