extends StateMachine

@export var air_state : StateMachine

var speed
func _on_enter():
	animationPlayer.play('bow')
	print('State sssssssssssenter:', self.name)
	print('State speed:', speed)
	character.collision_mask &= ~2
func state_process(delta):
	print('State character.velocity.x:', character.velocity.x)
	#if abs(character.velocity.x)<=100:
	#	next_state = air_state
	character.velocity.x = move_toward(character.velocity.x, speed,ACCELERATION_SPEED * delta)
	speed=character.velocity.x/1.02
	print('State character.velocity.x:', character.velocity.x)
	character.gun.shoot(character.sprite.scale.x)
func _on_animation_finished_player_(anim_name):
	if anim_name == 'bow':
		character.velocity.x=character.velocity.x/4
		character.collision_mask |= 2
		next_state = air_state
		pass
	
