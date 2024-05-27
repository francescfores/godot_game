extends StateMachine

@export var ground_state:StateMachine
	
func _on_enter():
	WALK_SPEED = 600.0
	animationPlayer.play('pray')
	print('State enter:', self.name)
	pass # Replace with function body.

func _on_animation_finished_player_(anim_name):
	print('animation_finished enter:', next_state)
	next_state = ground_state
	
