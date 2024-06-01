extends Node
class_name MachineState3

@export var character : CharacterBody2D
@export var animationPlayer : AnimationPlayer
@export var sprite : Sprite2D
@export var auroa_material : ShaderMaterial
@export var current_state : StateMachine
@export var hurt_state : StateMachine
@export var death_state : StateMachine
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
	
	character.level_node = get_tree().get_root().get_node("Level")
	# Asegúrate de que `level_node` tiene un nodo `Hangables`
	if character.level_node:
		var hangables =character. level_node.get_node("Level").get_node("Hangables")
		var climbs =character. level_node.get_node("Level").get_node("climbs")
		if hangables:
			for saliente in hangables.get_children():
				if saliente is Area2D:
					saliente.connect("player_can_hang", Callable(self, "_on_player_can_hang"))
					saliente.connect("player_cannot_hang",  Callable(self, "_on_player_cannot_hang"))
		if climbs:
			for climb in climbs.get_children():
				if climb is Area2D:
					climb.connect("player_can_climb", Callable(self, "_on_player_can_climb"))
					climb.connect("player_cannot_climb",  Callable(self, "_on_player_cannot_climb"))

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
	current_state._on_animation_finished_player_(anim_name)
func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.has_meta("owner"):
		var enemy = area.get_meta("owner")		
		recibir_dano(enemy.damage)
		if character.vida_actual==0:
			current_state.next_state = death_state
		else:	
			current_state.next_state = hurt_state
			character.blood_animation_player.play('blood_1')
			create_label_damage()
			if enemy.global_position.x < character.global_position.x:
				character.blood_sprite.flip_h = false
				character.blood_sprite.offset.x = 50
			else:
				character.blood_sprite.flip_h = true
				character.blood_sprite.offset.x = -50
		
		
	else:
		pass
		#print('Area entered by unknown entity')


var label_damage_timer: Timer
var label_damage_interval: float = 1.5
		
func create_label_damage():
	var new_vbox = character.damage_zone.get_node("damage_label").duplicate()  # Clonar el VBoxContainer template
	# Configurar el Label del nuevo VBoxContainer
	var label = new_vbox.get_node("label")
	if label:
		label.text = '10'
	else:
		print("Error: Label node not found in VBoxContainer template!")
	label.visible=true
	character.damage_zone.add_child(new_vbox) 
	label_damage_timer = Timer.new()
	label_damage_timer.connect("timeout",Callable(self, "_on_timer_timeout").bind(new_vbox) )
	label_damage_timer.one_shot = true
	label_damage_timer.wait_time = label_damage_interval
	add_child(label_damage_timer)
	label_damage_timer.start(label_damage_timer.wait_time)	

# Crear un Tween para animar el label
	var tween = get_tree().create_tween()
	tween.tween_property(new_vbox, "modulate", Color.RED, 0.3)
	#tween.tween_property(new_vbox, "position:x", 200.0, 1).as_relative()
	tween.tween_property(new_vbox, "position:y", -60.0, 1).as_relative()
	tween.tween_property(new_vbox, "scale", Vector2(label.global_position.x, label.global_position.y-100), 0.5)
	tween.tween_callback(new_vbox.queue_free)
	# Conectar la señal de finalización del tween para eliminar el VBoxContainer
	tween.connect("finished", Callable(self, "_on_tween_finished").bind(new_vbox))

func recibir_dano(cantidad):
	character.vida_actual -= cantidad
	character.vida_actual = clamp(character.vida_actual, 0, character.vida_maxima)
	actualizar_barra_vida() 
func actualizar_barra_vida():
	var proporción_vida = float(character.vida_actual) / character.vida_maxima
	character.barra_actual.size.x = proporción_vida * character.barra_fondo.size.x	
func _on_sword_2d_area_entered(area):
	print('eeeeeeee')
	print(area.name)
	if area.name == "EnemyDemon":
		area.recibir_dano(character.damage)
		area.animationPlayer('hurt')
func _on_sword_2d_body_entered(body):
	print('_on_sword_2d_body_entered')
	print(body.name)
	if body.name == "EnemyDemon":
		body.recibir_dano(character.damage)
func _on_player_can_hang(position):
	current_state._on_player_can_hang(position)
func _on_player_cannot_hang():
	current_state._on_player_cannot_hang()
func _on_player_can_climb(position):
	current_state._on_player_can_climb(position)
func _on_player_cannot_climb():
	current_state._on_player_cannot_climb()
