extends Label

@export var machine_state: MachineState
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if machine_state.current_state!=null:
		self.text = machine_state.current_state.name
