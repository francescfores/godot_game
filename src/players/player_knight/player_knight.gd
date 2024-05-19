class_name PlayerKnight extends CharacterBody2D

signal coin_collected()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer_wario as AnimationPlayer
@onready var animation_player2 := $AnimatedSprite2D as AnimatedSprite2D
@onready var sprite := $Sprite2D_wario as Sprite2D

#@onready var animation_player := $AnimationPlayer as AnimationPlayer
#@onready var sprite := $Sprite2D as Sprite2D

@onready var shoot_timer := $ShootAnimation as Timer

@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D
var _double_jump_charged := false
@export var wall_slide_gravity = 100
@export var wall_push_back = 200
var is_wall_slide = 200
var direction = 0
var attack_number='';

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_double_jump_charged = true


	if Input.is_action_just_pressed("move_left" + action_suffix) :
		direction = 1
	elif Input.is_action_just_pressed("move_right" + action_suffix) :
		direction = -1
				
	if is_on_wall() and Input.is_action_just_pressed("jump" + action_suffix) :
		velocity.x = wall_push_back * direction
		direction=direction*direction
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			$AnimatedSprite2D.flip_h = false
			sprite.scale.x = 2
		else:
			$AnimatedSprite2D.flip_h = true
			sprite.scale.x = -2

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	if Input.is_action_just_pressed("shoot" + action_suffix):
		is_shooting = gun.shoot(sprite.scale.x)

	if combo_timer > COMBO_MAX_TIME:
		is_attack=false
	
	print_debug(is_attack)	
	#var animation := get_new_animation(is_shooting)
	#if animation != animation_player.current_animation and shoot_timer.is_stopped():
		#if is_shooting:
			#shoot_timer.start()
	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and !is_attack:
		if is_shooting:
			shoot_timer.start()
		#animation_player.play(animation)
		animation_player2.play(animation)
	
	#animation_player2.play(animation)
		
func get_new_animation(is_shooting := false) -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
			if Input.is_action_pressed("move_down" + action_suffix):
				animation_new='crouch'
	else:
		if velocity.y > 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	#if is_shooting:
	#	animation_new += "_attack"
	return animation_new

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged :
		if !is_on_wall():
			_double_jump_charged = false
			
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	#jump_sound.play()

# Enumeramos los posibles estados de ataque
enum AttackState { IDLE, ATTACK_1, ATTACK_2, ATTACK_3 }
# Tiempo máximo entre ataques para que se considere un combo
const COMBO_MAX_TIME = 1
# Variables para el manejo del combo
var current_attack_state = AttackState.ATTACK_1
var combo_timer = 0.0
# Variables de entrada (esto asume que ya tienes configuradas las acciones en el Input Map)
var attack_input = "shoot" + action_suffix
var is_attack = false

func _process(delta):
	handle_input(delta)
	update_combo_timer(delta)

func handle_input(delta):
	if Input.is_action_just_pressed(attack_input) and Input.is_action_pressed('move_down'):
		current_attack_state = AttackState.ATTACK_1
		combo_timer = 0.0
		is_attack=true
		animation_player2.play("slide")
	elif Input.is_action_just_pressed(attack_input):
		handle_attack()

func handle_attack():
	is_attack=true
	match current_attack_state:
		AttackState.IDLE:
			current_attack_state = AttackState.ATTACK_1
			perform_attack(1)
		AttackState.ATTACK_1:
			if combo_timer < COMBO_MAX_TIME:
				current_attack_state = AttackState.ATTACK_2
				perform_attack(2)
		AttackState.ATTACK_2:
			if combo_timer < COMBO_MAX_TIME:
				current_attack_state = AttackState.ATTACK_3
				perform_attack(3)
		AttackState.ATTACK_3:
			if combo_timer < COMBO_MAX_TIME:
				current_attack_state = AttackState.ATTACK_1
				#perform_attack(1)
	# Reiniciar el temporizador de combo cada vez que se hace un ataque
	combo_timer = 0.0

func perform_attack(attack_number):
	# Aquí es donde realizas la lógica de ataque real, como animaciones y detección de colisiones
	animation_player2.play("idle_attack_%d"% attack_number)

func update_combo_timer(delta):
	if current_attack_state != AttackState.IDLE:
		combo_timer += delta
		if combo_timer > COMBO_MAX_TIME:
			current_attack_state = AttackState.IDLE
