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
@export var wall_push_back = 5000
var is_wall_slide = false
var wall_slide_timer = 0.5
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
enum AttackState { IDLE, ATTACK_1, ATTACK_2, ATTACK_3 }
# Tiempo máximo entre ataques para que se considere un combo
const COMBO_MAX_TIME = 1
# Variables para el manejo del combo
var current_attack_state = AttackState.ATTACK_1
var combo_timer = 0.0
# Variables de entrada (esto asume que ya tienes configuradas las acciones en el Input Map)
var attack_input = "shoot" + action_suffix
var is_attack = false
var is_slide = false
var is_attack_jump_down = false
var is_pray = false
#func _process(delta):
	#handle_input(delta)
	#update_combo_timer(delta)
var level_node = null


func _physics_process(delta: float) -> void:
	handle_input(delta)
	update_combo_timer(delta)
		
	if is_on_floor():
		_double_jump_charged = true
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	if !is_hanging and !is_wall_slide and  combo_timer>COMBO_MAX_TIME:
		velocity.x = move_toward(velocity.x, direction,ACCELERATION_SPEED * delta)

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


	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and shoot_timer.is_stopped():
		if is_shooting:
			shoot_timer.start()
	
	if is_slide and !is_on_floor():
		is_slide=false
		combo_timer = COMBO_MAX_TIME
		
		
	if is_attack_jump_down and is_on_floor():
		is_attack_jump_down=false
		combo_timer = 0.6
		animation_player2.play("jumping_attack_2")
		
		
	if !is_wall_slide and combo_timer>COMBO_MAX_TIME and !is_hanging and !is_attack and !is_slide and !is_attack_jump_down and !is_pray:
		#if is_shooting:
		#	shoot_timer.start()
		animation_player.play(animation)
		animation_player2.play(animation)
	
	
	if is_hanging:
		if Input.is_action_just_pressed("jump"):
			print_debug('is_hanging false')
			is_hanging = false
			#velocity.y = JUMP_FORCE
		return
		
		
	if can_hang and Input.is_action_just_pressed("ui_up"):	
		animation_player2.play('hanging')
		# Obtener la posición global del jugador
		var player_position = global_position
		# Determinar la dirección hacia el punto de colisión
		var offset=0
		# Si el punto de colisión está a la derecha del jugador

			
		_double_jump_charged = true
		print_debug('can_hang true')
		#get_tree().change_scene_to_file("res://src/scenes/main.tscn")
		is_hanging = true
		velocity = Vector2()
		gravity=0
		#global_position = hang_position
		var collision_shape_node = $CollisionShape2D
		var shape = collision_shape_node.shape
		print("Tamaño del RectangleShape2D:", shape)
		#global_position=hang_position
		if shape is CapsuleShape2D:
			var radius = shape.radius
			var height = shape.height
			print("Radio del CapsuleShape2D:", radius)
			print("Altura del CapsuleShape2D:", height)
			print("Altura del hang_position:", hang_position)
			var direction_to_hang = hang_position - player_position
			
			if direction_to_hang.x > 0:
				offset=20
				$AnimatedSprite2D.flip_h = false
				global_position = Vector2(hang_position.x-offset, hang_position.y + height/2+10)
		# Si el punto de colisión está a la izquierda del jugador
			else:
				$AnimatedSprite2D.flip_h = true
				offset=20
				global_position = Vector2(hang_position.x+offset, hang_position.y + height/2+10)
		if shape is RectangleShape2D:
			var size = shape.extents * 2 # extents es la mitad del tamaño total
			print("Tamaño del RectangleShape2D:", size)
		elif shape is CircleShape2D:
			var radius = shape.radius
			print("Radio del CircleShape2D:", radius)
		# Puedes agregar más condiciones para otros tipos de formas si las necesitas
	else:
		gravity = ProjectSettings.get("physics/2d/default_gravity")
		return

	#velocity.y += hang_gravity * delta
	#velocity = move_and_slide(velocity, Vector2.UP)
	
func get_last_movement_direction():
	# Obtener la dirección del último movimiento utilizando la velocidad
	var slide_collisions = get_slide_collision_count()
	if slide_collisions > 0:
		var collision = get_slide_collision(0)
		var normal = collision.normal
		return normal.normalized()
	else:
		return Vector2.ZERO
		
func handle_input(delta):
	if Input.is_action_just_pressed(attack_input) and is_on_floor() and Input.is_action_pressed('move_down'):
		current_attack_state = AttackState.ATTACK_1
		combo_timer = 0.0
		is_slide=true
		animation_player2.play("slide")
	elif Input.is_action_just_pressed(attack_input) and !is_on_floor() and Input.is_action_pressed('move_down'):
		current_attack_state = AttackState.ATTACK_1
		combo_timer = 0.0
		is_attack_jump_down=true
		animation_player2.play("jumping_attack_1")
	elif Input.is_action_just_pressed(attack_input):
		is_attack=true
		handle_attack()
		
	if Input.is_action_pressed("move_left" + action_suffix) :
		direction = -1
	elif Input.is_action_pressed("move_right" + action_suffix) :
		direction = 1
	
	if is_on_wall() and !is_hanging:
		velocity.y=170
		velocity.x=0
		if direction==1:
			direction = -1
		else:
			direction = 1
			
	if is_on_wall() and Input.is_action_just_pressed("jump" + action_suffix):
		timer=0.2
		is_wall_slide = true;
		velocity.x = (wall_push_back*3) * direction
		velocity.y = JUMP_VELOCITY*1.5
		_double_jump_charged = false
	if is_wall_slide and timer>wall_slide_timer:
		is_wall_slide = false;
		
		
	if Input.is_action_just_pressed("jump" + action_suffix):

		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	if Input.is_action_pressed("pray" + action_suffix):
		animation_player2.play("pray")
		is_pray=true
	else:
		is_pray=false
		
func play_animation(animation) -> void:
	animation_player2.play(animation)
			
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
		_double_jump_charged = false			
		velocity.x *= 2.5
		jump_sound.pitch_scale = 4
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()


func handle_attack():
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
	timer += delta
	if combo_timer > COMBO_MAX_TIME:
		is_attack=false
		is_slide=false
		is_attack_jump_down=false
	if current_attack_state != AttackState.IDLE:
		combo_timer += delta
		if combo_timer > COMBO_MAX_TIME:
			current_attack_state = AttackState.IDLE



func _ready():
	# Obtener una referencia al nodo Level
	level_node = get_tree().get_root().get_node("Level")
	# Asegúrate de que `level_node` tiene un nodo `Hangables`
	if level_node:
		var hangables = level_node.get_node("Level").get_node("Hangables")
		if hangables:
			for saliente in hangables.get_children():
				if saliente is Area2D:
					saliente.connect("player_can_hang", Callable(self, "_on_player_can_hang"))
					saliente.connect("player_cannot_hang",  Callable(self, "_on_player_cannot_hang"))


func _on_player_can_hang(position):
	can_hang = true
	hang_position = position

func _on_player_cannot_hang():
	can_hang = false
	is_hanging = false
