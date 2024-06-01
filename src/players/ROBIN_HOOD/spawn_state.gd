extends StateMachine

@export var ground_state:StateMachine
	
func _on_enter():
	WALK_SPEED = 600.0
	character.global_position.x = character.initial_position.x
	character.global_position.y = character.initial_position.y	
	animationPlayer.play('pray')
	print('State enter:', self.name)
	character.vida_actual=100
	actualizar_barra_vida()
	pass # Replace with function body.

func _on_animation_finished_player_(anim_name):
	print('animation_finished enter:', next_state)
	next_state = ground_state
	
func actualizar_barra_vida():
	var proporción_vida = float(character.vida_actual) / character.vida_maxima
	character.barra_actual.size.x = proporción_vida * character.barra_fondo.size.x
	print(proporción_vida)
	print(character.vida_actual)
