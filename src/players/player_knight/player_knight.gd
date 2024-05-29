class_name PlayerKnight extends CharacterBody2D

@export var machine_state: MachineState
signal coin_collected()

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""
var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer_wario as AnimationPlayer
@onready var animation_player2 := $AnimatedSprite2D as AnimatedSprite2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var sword := $Sprite2D/Sword2D as Area2D
@onready var shoot_timer := $ShootAnimation as Timer
@onready var blood_animation_player := $damage_zone/AnimationPlayer as AnimationPlayer
@onready var blood_sprite := $damage_zone/Sprite2D as Sprite2D
@onready var damage_zone := $damage_zone as Area2D

@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D

var timer =  0.0
var direction = 0
var attack_number='';
var is_hanging = false
var can_hang = false
var hang_position = Vector2()

var hang_gravity = 0
const JUMP_FORCE = -300
#var velocity = Vector2()
# Enumeramos los posibles estados de ataque
enum AttackState { IDLE, ATTACK_1, ATTACK_2, ATTACK_3, ATTACK_4 }
# Tiempo máximo entre ataques para que se considere un combo
var COMBO_MAX_TIME = 0.8
# Variables para el manejo del combo
var current_attack_state = AttackState.ATTACK_1
var combo_timer = 0.0
# Variables de entrada (esto asume que ya tienes configuradas las acciones en el Input Map)
var attack_input = "shoot" + action_suffix
var is_attack = false
var is_attack_jump_down = false
var is_pray = false
#func _process(delta):
	#handle_input(delta)
	#update_combo_timer(delta)
var level_node = null

#new
#en new


func _physics_process(delta: float) -> void:
	velocity.y = minf(machine_state.current_state.TERMINAL_VELOCITY, velocity.y + gravity * delta)
	floor_stop_on_slope = not platform_detector.is_colliding()
	var direction2=0
	if machine_state.current_state.can_move:
		direction2= Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * machine_state.current_state.WALK_SPEED
	if !is_hanging  :# and  combo_timer>COMBO_MAX_TIME:
			velocity.x = move_toward(velocity.x, direction2,machine_state.current_state.ACCELERATION_SPEED * delta)
	if direction2>0:
		direction = 1
	else:
		direction = -1		
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = 2.5
		else:
			sprite.scale.x = -2.5 
	#refactor(delta)
	move_and_slide()
@onready var area_sword = $Sprite2D/Sword2D
var initial_position = Vector2()
func _ready():
	area_sword.set_meta("player", self)
	initial_position = sprite.global_position
	# Obtener una referencia al nodo Level
	level_node = get_tree().get_root().get_node("Level")
	# Asegúrate de que `level_node` tiene un nodo `Hangables`
	if level_node:
		var hangables = level_node.get_node("Level").get_node("Hangables")
		if hangables:
			for saliente in hangables.get_children():
				pass
				#if saliente is Area2D:
				#	saliente.connect("player_can_hang", Callable(self, "_on_player_can_hang"))
				#	saliente.connect("player_cannot_hang",  Callable(self, "_on_player_cannot_hang"))

@onready var barra_vida = $Node2D/BarraVidas
@onready var barra_fondo = barra_vida.get_node("Fondo")
@onready var barra_actual = barra_vida.get_node("VidaActual")
var vida_maxima = 100
var vida_actual = 100
var damage =5
