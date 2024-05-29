extends StateMachine

@export var ground_state : StateMachine

func _on_exit():
	character.gravity = ProjectSettings.get("physics/2d/default_gravity")
	can_climb=false
	next_state = ground_state
		
func _on_enter():
	print('State pray:', self.name)
	animationPlayer.play('climb')
	character.velocity.y=0
	character.gravity=0
	can_climb=true
	character.global_position.x=climb_position.x
func state_process(delta):
	var direction2= Input.get_axis("move_up" + character.action_suffix, "move_down" + character.action_suffix) * WALK_SPEED
	character.velocity.y = move_toward(character.velocity.y, direction2,ACCELERATION_SPEED * delta)
	if !can_climb:
		character.gravity = ProjectSettings.get("physics/2d/default_gravity")
		next_state = ground_state
		
func state_input(event:InputEvent):	
	pass
func _on_animation_finished_player_(anim_name):
	pass
	#if anim_name == 'pray':
		#next_state = ground_state
	
func _on_player_cannot_climb():
	can_climb=false
