extends StateMachine

@export var ground_state : StateMachine
@export var crouch_state : StateMachine
@export var crouch_attack_1_state : StateMachine
var repeat = false
func _on_enter():
	print('State doooooooooooooooooo:', self.name)
	animationPlayer.play('crouch')
func state_input(event:InputEvent):	
	if event.is_action_pressed("jump" +  character.action_suffix):
		next_state = ground_state
	if event.is_action_released("move_down" +  character.action_suffix):
		repeat=true
		next_state = ground_state
	if event.is_action_pressed("shoot" +  character.action_suffix):
		next_state=crouch_attack_1_state
func state_process(delta):
	if abs(character.velocity.x) > 0 or abs(character.velocity.y) > 0:
		pass
		next_state = ground_state

func _on_animation_finished_player_(anim_name):
	if anim_name == 'crouch':
		if repeat:
			next_state = crouch_state
		else:
			next_state = ground_state
		
