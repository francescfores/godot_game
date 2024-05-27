extends Node
class_name StateMachine


var WALK_SPEED = 300.0
var ACCELERATION_SPEED = WALK_SPEED * 6.0
var JUMP_VELOCITY = -700.0
## Maximum speed at which the player can fall.
var TERMINAL_VELOCITY = 400

var character : CharacterBody2D
var animationPlayer : AnimationPlayer
var sprite : AnimationPlayer
var auroa_material :ShaderMaterial
var new_state : StateMachine = null
var next_state : StateMachine = null

@export var can_move=true

func state_process(delta):
	pass

func state_input(input):
	pass


func _ready():
	WALK_SPEED = 500.0
	
# Called when the node enters the scene tree for the first time.
func _on_enter():
	print('State enterdsdsd:', self.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_exit():
	print('State enter:', self.name)


func _on_animation_finished_player_(anim_name):
	print('_on_animation_finished_player__on_animation_finished_player__on_animation_finished_player_')
