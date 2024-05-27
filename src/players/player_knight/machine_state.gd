extends Node
class_name MachineState

@export var character : CharacterBody2D
@export var animationPlayer : AnimationPlayer

@export var current_state : StateMachine
@export var action_suffix := ""

var ArrayStates: Array[StateMachine]
func _ready():
	animationPlayer.play('death')
	for child in self.get_children():
		if child is StateMachine:
			child.character = character
			child.animationPlayer = animationPlayer
			ArrayStates.append(child)
			
	print(ArrayStates)		
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
