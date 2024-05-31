extends Area2D

@export var escena := ""

@export var climb_position_offset := Vector2(0, -16) # Ajusta según tu sprite

# Señales para notificar al personaje que puede colgarse
signal player_can_climb(climb_position)
signal player_cannot_climb()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_can_climb", global_position) #+ hang_position_offset)
		#get_tree().change_scene_to_file("res://src/scenes/scene_4/switch_level.tscn")

func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("player_cannot_climb")
