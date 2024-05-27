extends Node
class_name MachineState

@export var character : CharacterBody2D
@export var animationPlayer : AnimationPlayer
@export var sprite : Sprite2D
@export var auroa_material : ShaderMaterial
@export var current_state : StateMachine
@export var hurt_state : StateMachine
@export var action_suffix := ""
var ArrayStates: Array[StateMachine]
func _ready():
	animationPlayer.play('death')
	for child in self.get_children():
		if child is StateMachine:
			child.character = character
			child.animationPlayer = animationPlayer
			child.sprite = sprite
			child.auroa_material = sprite.material
			ArrayStates.append(child)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if current_state.next_state!=null:
		change_state(current_state.next_state)
	
	current_state.state_process(delta)
func _input(event:InputEvent):
	current_state.state_input(event)

func change_state(new_state):
	current_state._on_exit()
	current_state.next_state=null
	current_state=new_state
	current_state._on_enter()
	


func _on_animation_finished_player_(anim_name):
	#if current_state!=null:
	current_state._on_animation_finished_player_(anim_name)

func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.has_meta("owner"):
		var enemy = area.get_meta("owner")
		recibir_dano(10)
		current_state.next_state = hurt_state
	else:
		pass
		#print('Area entered by unknown entity')


# Variables de salud
var vida_maxima = 100
var vida_actual = 100
#func _on_area_2d_area_entered(area):
#	print('areaaaaaaaaaaaaaaaaa')
func recibir_dano(cantidad):
	vida_actual -= cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	actualizar_barra_vida()
 
func actualizar_barra_vida():
	var proporción_vida = float(vida_actual) / vida_maxima
	character.barra_actual.size.x = proporción_vida * character.barra_fondo.size.x
