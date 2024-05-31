extends StateMachine

@export var ground_state : StateMachine

func _on_enter():
	print('State pray:', self.name)
	animationPlayer.play('pray')
func state_input(event:InputEvent):	
	if event.is_action_pressed("pray" + character.action_suffix):
		next_state=ground_state
func _on_animation_finished_player_(anim_name):
	pass
	#if anim_name == 'pray':
		#next_state = ground_state
	
