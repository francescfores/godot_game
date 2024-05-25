class_name EnemyDeamon extends CharacterBody2D


enum State {
	WALKING,
	DEAD,
	FOLLOW,
	ATTACK,
	SPAWN,
	IDLE,
	COMBO
}

const WALK_SPEED = 150.0

var _state := State.WALKING

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer

var direction=1
			
func _physics_process(delta: float) -> void:
	
	if  _state == State.WALKING and velocity.is_zero_approx():
		velocity.x = WALK_SPEED * direction
	velocity.y += gravity * delta
	if _state == State.WALKING and not floor_detector_left.is_colliding():
		direction =1
		velocity.x = WALK_SPEED
	elif _state == State.WALKING and not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED
		direction =-1

	if  _state == State.WALKING and  is_on_wall() :
		velocity.x = -velocity.x
	if  _state == State.ATTACK  :
		velocity.x = 0
	move_and_slide()

	if velocity.x > 0.0:
		sprite.scale.x = 0.8
	elif velocity.x < 0.0:
		sprite.scale.x = -0.8

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)
		#mover_hacia_objetivo(delta)

func destroy() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO


func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.WALKING:
		if velocity.x == 0:
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	else:
		animation_new = &"destroy"
	return animation_new


# Variables de salud
var vida_maxima = 100
var vida_actual = 100
# Variables para el movimiento
var velocidad = 100
var jugador_visto = false
var objetivo = null


# Referencias a los nodos de la barra de vida
@onready var barra_vida = $Node2D/BarraVidas
@onready var barra_fondo = barra_vida.get_node("Fondo")
@onready var barra_actual = barra_vida.get_node("VidaActual")
@onready var area_vision = $Area2D
@onready var area_attack = $AttackArea2D
@onready var area_sword = $Sprite2D/Sword2D


	
func _ready():
	actualizar_barra_vida()
	area_vision.connect("body_entered", Callable(self, "_on_area_2d_area_entered"))
	area_vision.connect("body_exited", Callable(self, "_on_area_2d_area_exited"))
	area_attack.connect("body_entered", Callable(self, "_on_attack_area_2d_area_entered"))
	area_attack.connect("body_exited", Callable(self, "_on_attack_area_2d_area_exited"))
	area_sword.connect("body_entered", Callable(self, "_on_sword_2d_area_entered"))
func mover_hacia_objetivo(delta):
	var direccion = (objetivo.global_position - global_position).normalized()
	#move_and_slide(direccion * velocidad)
	move_and_slide()
	
func recibir_dano(cantidad):
	vida_actual -= cantidad
	vida_actual = clamp(vida_actual, 0, vida_maxima)
	actualizar_barra_vida()
var is_combo=false
func actualizar_barra_vida():
	var proporción_vida = float(vida_actual) / vida_maxima
	barra_actual.size.x = proporción_vida * barra_fondo.size.x
var timer=0.0
var delay=1.0;
func _process(delta):
	timer += delta
		#animation_player.play('spawn')
	if _state == State.IDLE :
		#animation_player.play('idle')
		velocity.x=0
	if _state == State.FOLLOW :
		#animation_player.play('idle')
		follow_player()
	# Manejo de combos
	if is_combo:
		distance_to_player = player.global_position - global_position
		if on_attack_area:
			combo_timer += delta
			var current_action = combo_actions[current_combo_index]
			if combo_timer > current_action.duration:
				combo_timer = 0.0
				current_combo_index += 1
				if current_combo_index >= combo_actions.size():
					_state = State.IDLE  # Termina el combo y vuelve a IDLE
					current_combo_index = -1
				else:
					if player.global_position.x < global_position.x:
						sprite.scale.x = -1
					else :
						sprite.scale.x = 1
						
					_state = current_action.state
					# Ejecuta la siguiente acción del combo
					current_action = combo_actions[current_combo_index]
					animation_player.play(current_action.animation)
					if current_action.name == "spawn":
						teletransportar_detras_del_jugador(player)
					#if current_action.name == "follow":
					#	follow_player()
		else :
			is_combo=false
			_state = State.FOLLOW
var attack_distance=Vector2(150, 250)
var distance_to_player=Vector2(0, 0)

func follow_player():
	distance_to_player = player.global_position - global_position

	if abs(distance_to_player.x) < attack_distance.x and abs(distance_to_player.y) < attack_distance.y:
		#animation_player.play('attack_1')
		velocity.x=0
		#start_combo()

	if  _state == State.FOLLOW and velocity.is_zero_approx():
			velocity.x = WALK_SPEED * direction
	if abs(distance_to_player.x) > attack_distance.x :
		animation_player.play('walk')
		if distance_to_player.x > attack_distance.x:
			direction =1
			velocity.x = WALK_SPEED
		elif distance_to_player.x < attack_distance.x:
			velocity.x = -WALK_SPEED
			direction =-1
	
		
var player

func _on_area_2d_area_entered(body):
	if body.name == "Player":
		print_debug('followwwww _on_area_2d_area_entered')
		#jugador_visto = true
		objetivo = body
		player = body
		_state=State.FOLLOW
		distance_to_player = player.global_position - global_position
		
func _on_area_2d_area_exited(body):
	if body.name == "Player":
		#jugador_visto = false
		objetivo = null
		#if velocity.x > 0.0:
			#velocity.x=-WALK_SPEED
		#elif velocity.x < 0.0:
			#velocity.x=WALK_SPEED
		_state = State.WALKING
		is_combo=false
var teleport_distance := 100.0
func teletransportar_detras_del_jugador(player):
	var player_position = player.global_position
	var direction := Vector2(-1, 0)  # Dirección inicial (izquierda)
	sprite.scale.x = -1
	velocity.x=0
	if player.global_position.x < global_position.x:
		direction = Vector2(1, 0)  # Cambiar dirección a derecha si el jugador mira a la derecha
		sprite.scale.x = 1
	var new_position = player_position - direction * teleport_distance
	self.global_position = new_position

class ComboAction:
	var name: String
	var duration: float
	var animation: String
	var state: State

	func _init(name: String, duration: float, animation: String, state: State):
		self.name = name
		self.duration = duration
		self.animation = animation
		self.state = state
		
var combo_actions = [
	ComboAction.new("attack_2", 1, "attack_2", State.ATTACK),
	ComboAction.new("attack_2", 1, "attack_2", State.ATTACK),
	ComboAction.new("attack_2", 1, "attack_2", State.ATTACK),
	ComboAction.new("attack_2", 1, "attack_2", State.ATTACK),
	ComboAction.new("attack_1", 1, "attack_1", State.ATTACK),
]

var current_combo_index = 0
var combo_timer = 0.0

# Iniciar combo
func start_combo():
	if !is_combo:
		is_combo=true
		current_combo_index = -1
		#animation_player.play(combo_actions[current_combo_index].animation)
		#if combo_actions[current_combo_index].name == "spawn":
		#	teletransportar_detras_del_jugador(player)

var on_attack_area=false
func _on_attack_area_2d_area_entered(area):
	if area.name == "Player":
		print_debug('atttack _on_attack_area_2d_area_entered')
		on_attack_area=true
		start_combo()
	pass # Replace with function body.


func _on_attack_area_2d_area_exited(area):
	if area.name == "Player":
		on_attack_area=false
		is_combo=false
		_state=State.FOLLOW
	
	#current_combo_index = 0
	#combo_timer=0.0
	pass # Replace with function body.

var i =0
func _on_sword_2d_area_entered(area):
		if area.name == "Player":
			i=1+i
			area.test = true
			area._state = area.State.HURT
			area.combo_timer = 0.0
			area.animation_player.play("idle_attack_1")
			print_debug(area._state)
