extends Node
class_name StateMachine


var WALK_SPEED = 400.0
var ACCELERATION_SPEED = WALK_SPEED * 12.0
var JUMP_VELOCITY = -800.0
## Maximum speed at which the player can fall.
var TERMINAL_VELOCITY = 700

var character : CharacterBody2D
var animationPlayer : AnimationPlayer
var sprite : AnimationPlayer
var auroa_material :ShaderMaterial
var new_state : StateMachine = null
var next_state : StateMachine = null

@export var can_move=true
@export var can_hang=false
@export var can_climb=false
var hang_position
var climb_position

func state_process(delta):
	pass

func state_input(input):
	pass


func _ready():
	WALK_SPEED = 500.0
	
# Called when the node enters the scene tree for the first time.
func _on_enter():
	#print('State enterdsdsd:', self.name)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_exit():
	#print('State enter:', self.name)
	pass


func _on_animation_finished_player_(anim_name):
	#print('_on_animation_finished_player__on_animation_finished_player_')
	pass

func _on_player_can_hang(position):
	can_hang=true
	hang_position=position
	print('_on_player_can_hang2')
func _on_player_cannot_hang():
	can_hang=false
	print('_on_player_cannot_hang2')


func _on_player_can_climb(position):
	can_climb=true
	climb_position=position
	print('_on_player_can_climb2', climb_position)
func _on_player_cannot_climb():
	can_climb=false
	print('_on_player_cannot_climb2')
