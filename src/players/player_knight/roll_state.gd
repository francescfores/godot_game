extends StateMachine

@export var air_state : StateMachine

func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('roll')
	character.collision_mask &= ~2
	
func state_process(delta):
	#if abs(character.velocity.x) <10:
	#	character.collision_mask |= 2
	#	animationPlayer.play('idle')
	#	next_state = air_state
	pass
func _on_animation_finished_player_(anim_name):
	if anim_name == 'roll':
		character.collision_mask |= 2
		next_state = air_state
