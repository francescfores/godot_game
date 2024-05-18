class_name Main extends Node


var next_level = null

#Cargar la Escena o el nivel a elegir pero se tiene que
#agregar al nodo par coger la referencia $nombredelnodo
# y ocultar o quitar los otros
#@onready var current_level = $LevelsList
@onready var current_level = $menuLevel

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "handle_level_changed"))
	current_level.play_loaded_sound()


func handle_level_changed(current_level_name: String):
	var next_level_name: String
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/DesertLevel.tscn")
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/"+ next_level_name +"Level.tscn")
	print_debug(current_level_name)
	next_level_name = current_level_name
			
	print_debug(next_level_name)
	next_level = load("res://src/scenes/scene_"+ next_level_name +"/"+ next_level_name +".tscn").instantiate()
	#next_level = load("res://src/scenes/scene_levels/"+ next_level_name +"Level.tscn").instantiate()

	next_level.connect("level_changed", Callable(self, "handle_level_changed"))
	next_level.play_loaded_sound()
	#transfer_data_between_scenes(current_level, next_level)
	
	# Eliminar la escena actual antes de agregar la nueva
	if current_level:
		current_level.queue_free()
	
	# Establecer la nueva escena como la escena actual
	current_level = next_level
	
	add_child(next_level)

func transfer_data_between_scenes(old_scene: CanvasLayer, new_scene: CanvasLayer):
	if old_scene and new_scene:
		new_scene.load_level_parameters(old_scene.level_parameters)
