extends StateMachine

@export var ground_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('jump_attack_down_1')
	character.velocity.y = 900
func state_process(delta):
	if character.is_on_floor():
		animationPlayer.play('jump_attack_down_2')
		
func _on_animation_finished_player_(anim_name):
	if anim_name == 'jump_attack_down_2':
		next_state = ground_state
	
