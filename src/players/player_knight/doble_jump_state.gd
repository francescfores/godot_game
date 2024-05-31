extends StateMachine

@export var ground_state : StateMachine
@export var air_state : StateMachine
@export var attack_state : StateMachine

func state_input(event:InputEvent):
	if event.is_action_pressed("shoot" +  character.action_suffix):
		next_state=attack_state
func _on_enter():
	animationPlayer.play('jumping')

func _on_animation_finished_player_(anim_name):
	if anim_name == 'jumping':
		next_state = ground_state if character.is_on_floor() else air_state
	
