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
@onready var sword := $Sprite2D_wario/Sword2D as Area2D
@onready var shoot_timer := $ShootAnimation as Timer

@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D
var _double_jump_charged := false
@export var wall_slide_gravity = 100
@export var wall_push_back = 200
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

enum State {
	IDLE,
	WALKING,
	JUMP,
	FALLING,
	ATTACK,
	SLIDE,
	HANGING,
	DEATH,	
	SPAWN,
	COMBO,
	CLIMB,
	CROUCH,
	CROUCH_ATTACK,
	DASH,
	DEAD,
	HEALT,
	HURT,
	IDLE_ATTACK,
	JUMP_ATTACK,	
	PRAY,
	ROLL,
	RUN
}

var _state := State.IDLE
func handle_input(delta):
	#walk
	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	#if _state!=State.ATTACK and !is_hanging and !is_wall_slide and  combo_timer>COMBO_MAX_TIME:
	if _state!=State.HURT and _state!=State.ATTACK and !is_hanging and !is_wall_slide :# and  combo_timer>COMBO_MAX_TIME:
		velocity.x = move_toward(velocity.x, direction,ACCELERATION_SPEED * delta)
		
	#jump
	if _state!=State.SLIDE:
		if Input.is_action_just_pressed("jump" + action_suffix):
			if _state==State.HURT:
				_state=State.WALKING

			try_jump()
		elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
			# The player let go of jump early, reduce vertical momentum.
			velocity.y *= 0.6
			
		
	#slide
	if velocity.x!=0 and Input.is_action_just_pressed(attack_input) and is_on_floor() and Input.is_action_pressed('move_down'):
		current_attack_state = AttackState.ATTACK_1
		_state=State.SLIDE
		COMBO_MAX_TIME = 2
		combo_timer = 0.0
		#is_slide=true
		velocity.x = velocity.x*2.5
	if Input.is_action_just_pressed(attack_input):
		_state=State.ATTACK
		handle_attack()
	if Input.is_action_just_pressed(attack_input) and !is_on_floor() and Input.is_action_pressed('move_down'):
		current_attack_state = AttackState.ATTACK_1
		velocity.x=velocity.x/4
		combo_timer = 0.0
		is_attack_jump_down=true
		animation_player.play("jump_attack_down_1")
			
	if Input.is_action_pressed("move_left" + action_suffix) :
		direction = -1
	elif Input.is_action_pressed("move_right" + action_suffix) :
		direction = 1
	
	#jump on wall
	if is_on_wall() and !is_hanging:
		#velocity.y=170
		#velocity.x=0
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
				
	#pray
	if Input.is_action_pressed("pray" + action_suffix):
		animation_player.play("pray")
		is_pray=true
	else:
		is_pray=false
	
func _physics_process(delta: float) -> void:
	print(_state)		
	handle_input(delta)
	
	if _state==State.SLIDE and !is_on_floor():
		_state=State.IDLE
		combo_timer = COMBO_MAX_TIME
	if _state==State.HURT:
		print('eeeeeeeeeeeee')		
		#_state=State.HURT
		animation_player.play("hurt")
		velocity.y=0
		velocity.x=0
	elif abs(velocity.x) == 0 :
		_state=State.IDLE
		animation_player.play("idle")

	if abs(velocity.x) != 0 :
		_state=State.WALKING
		animation_player.play("waling")
	if velocity.y > 0.0:
		_state=State.FALLING
		animation_player.play("falling")
		
	#else:
	#	_state=State.JUMP
				

	update_combo_timer(delta)

	if is_on_floor():
		_double_jump_charged = true
	#fall
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	#flipsprite
	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			$AnimatedSprite2D.flip_h = false
			sprite.scale.x = 2.5
		else:
			$AnimatedSprite2D.flip_h = true
			sprite.scale.x = -2.5 
	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	#shoot
	var is_shooting := false
	#if Input.is_action_just_pressed("shoot" + action_suffix):
		#is_shooting = gun.shoot(sprite.scale.x)

	var animation := get_new_animation()
		#if is_shooting:
			#shoot_timer.start()
	
	if is_attack_jump_down and is_on_floor():
		is_attack_jump_down=false
		combo_timer = 0.6
		
	if !is_wall_slide and combo_timer>COMBO_MAX_TIME and !is_hanging and _state!=State.ATTACK and _state!=State.SLIDE and !is_attack_jump_down and !is_pray:
		#if is_shooting:
		#	shoot_timer.start()
		animation_player.play(animation)
	
	if is_hanging:
		if Input.is_action_just_pressed("jump"):
			print_debug('is_hanging false')
			is_hanging = false
			#velocity.y = JUMP_FORCE
		return
	if can_hang and Input.is_action_just_pressed("ui_up"):	
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
				sprite.scale.x = 2.5 
				global_position = Vector2(hang_position.x-offset, hang_position.y + height/2+10)
		# Si el punto de colisión está a la izquierda del jugador
			else:
				$AnimatedSprite2D.flip_h = true
				sprite.scale.x = -2.5 
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
func get_new_animation() -> String:
	var animation_new: String
	if _state==State.IDLE:
		animation_new = "idle"
	if _state==State.WALKING:
		animation_new = "walking"
	if _state==State.RUN:
		animation_new = "run"
	if _state==State.JUMP:
		animation_new = "jumping"
	if _state==State.FALLING:
		animation_new = "falling"
	#if _state==State.ATTACK:
	#	animation_player.play("idle_attack_1")	
	if _state==State.SLIDE:
		animation_new = "slide"
	if _state==State.HANGING:
		animation_new = "hanging"
	if _state==State.DEATH:
		animation_new = "death"
	if _state==State.SPAWN:
		animation_new = "spawn"
	#if _state==State.COMBO:
	#	animation_player.play("Combo")
	if _state==State.CLIMB:
		animation_new = "climb"
	if _state==State.CROUCH:
		animation_new = "crouch"
	if _state==State.CROUCH_ATTACK:
		animation_new = "crouch_attack"
	if _state==State.DASH:
		animation_player.play("dash")
	if _state==State.HEALT:
		animation_new = "healt"
	if _state==State.HURT:
		animation_new = "hurt"
	#if _state==State.IDLE_ATTACK:
	#	animation_player.play("hurt")	
	if _state==State.JUMP_ATTACK:
		animation_new = "jump_attack_down_2"
	if _state==State.PRAY:
		animation_new = "pray"
	if _state==State.ROLL:
		animation_new = "roll"						
	print('eeeeeeeeeeeee')		
	print(_state)		
		
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			#direction=0
			animation_new = "idle"
			if Input.is_action_pressed("move_down" + action_suffix):
				animation_new='crouch'
	else:
		if velocity.y > 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
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
var test=false
var wait_attack=0.4
var blink_timer: Timer
var blink_interval: float = 0.05
var should_blink: bool = false
@onready var auroa_material = sprite.material as ShaderMaterial

func _process(delta):
	print(test)
	if current_attack_state != AttackState.ATTACK_4 and combo_timer<COMBO_MAX_TIME and combo_timer>wait_attack:
		start_blinking()
		is_auroa_active=true
	else:
		stop_blinking()
		is_auroa_active=false
		
	# Aquí puedes poner la condición bajo la cual se activa/desactiva el material
	if is_auroa_active:
		_activate_auroa_material()
	else:
		_deactivate_auroa_material()

func _activate_auroa_material():
	auroa_material.set("shader_param/aura_width", 0.4) # Ajusta el valor según tus necesidades
	auroa_material.set("shader_param/aura_color", Color(0.70, 0.60, 0, 1)) # Ajusta el color según tus necesidades

func _deactivate_auroa_material():
	auroa_material.set("shader_param/aura_width", 0.0) # O cualquier valor que "desactive" visualmente el shader

var is_auroa_active = false

func handle_attack():
	#velocity.x=0
	if combo_timer>wait_attack:
		match current_attack_state:
			AttackState.IDLE:
				COMBO_MAX_TIME = 0.8
				wait_attack=0.4
				current_attack_state = AttackState.ATTACK_1
				velocity.x=velocity.x+ (60*direction)
				perform_attack(1)
			AttackState.ATTACK_1:
				if combo_timer < COMBO_MAX_TIME:
					COMBO_MAX_TIME = 0.8
					wait_attack=0.5
					current_attack_state = AttackState.ATTACK_2
					perform_attack(2)
					#start_blinking()
			AttackState.ATTACK_2:
				COMBO_MAX_TIME = 0.8
				if combo_timer < COMBO_MAX_TIME:
					current_attack_state = AttackState.ATTACK_3
					perform_attack(3)
					velocity.x=velocity.x+ (60*direction)
			AttackState.ATTACK_3:
				COMBO_MAX_TIME = 0.8
				if combo_timer < COMBO_MAX_TIME:
					current_attack_state = AttackState.ATTACK_4
					perform_attack(4)
			AttackState.ATTACK_4:
				COMBO_MAX_TIME = 0.8
				wait_attack=0.0
				
				if combo_timer < COMBO_MAX_TIME:
					current_attack_state = AttackState.ATTACK_1
					velocity.x=velocity.x+ (60*direction)
				#	current_attack_state = AttackState.ATTACK_1
					#perform_attack(1)
		# Reiniciar el temporizador de combo cada vez que se hace un ataque
		combo_timer = 0.0

func perform_attack(attack_number):
	# Aquí es donde realizas la lógica de ataque real, como animaciones y detección de colisiones
	animation_player.play("idle_attack_%d"% attack_number)

func update_combo_timer(delta):
	timer += delta

	if combo_timer > COMBO_MAX_TIME:
		#is_attack=false
		_state=State.IDLE
		is_attack_jump_down=false
	if _state != State.IDLE:
		combo_timer += delta
	if current_attack_state != AttackState.IDLE:
		combo_timer += delta
		#if combo_timer > COMBO_MAX_TIME:
			#current_attack_state = AttackState.IDLE
			#stop_blinking() 
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
					
	blink_timer = Timer.new()
	blink_timer.wait_time = blink_interval
	blink_timer.connect("timeout",Callable(self, "_on_blink_timer_timeout"))
	add_child(blink_timer)

func start_blinking():
	should_blink = true
	if blink_timer.is_stopped():
		blink_timer.start()

func stop_blinking():
	should_blink = false
	sword.visible = false
	blink_timer.stop()

func _on_blink_timer_timeout():
	if should_blink:
		sword.visible = not sword.visible
	else:
		sword.visible = true
		blink_timer.stop()
		
func _on_player_can_hang(position):
	can_hang = true
	hang_position = position

func _on_player_cannot_hang():
	can_hang = false
	is_hanging = false
