class_name Switch_level extends Node


var next_level = null

@onready var current_level = $LevelList

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "handle_level_changed"))
	current_level.play_loaded_sound()


func handle_level_changed(current_level_name: String):
	var next_level_name: String
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/DesertLevel.tscn")
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/"+ next_level_name +"Level.tscn")
	print_debug(current_level_name)
	match current_level_name:
		"grass":
			next_level_name = "Desert"
		"desert":
			next_level_name = "Grass"
		_:
			return
			
	print_debug(next_level_name)
	next_level = load("res://src/scenes/scene_4/levels/%sLevel.tscn" % next_level_name).instantiate()

	add_child(next_level)
	next_level.connect("level_changed", Callable(self, "handle_level_changed"))
	next_level.play_loaded_sound()
	#transfer_data_between_scenes(current_level, next_level)


func transfer_data_between_scenes(old_scene: CanvasLayer, new_scene: CanvasLayer):
	if old_scene and new_scene:
		new_scene.load_level_parameters(old_scene.level_parameters)

