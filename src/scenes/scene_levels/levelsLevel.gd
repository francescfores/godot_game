class_name LevelsMain extends Node

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu


var next_level = null

#Cargar la Escena o el nivel a elegir pero se tiene que
#agregar al nodo par coger la referencia $nombredelnodo
# y ocultar o quitar los otros
@onready var current_level = $DesertLevel

func _ready() -> void:
	current_level.connect("level_changed", Callable(self, "handle_level_changed"))
	#current_level.play_loaded_sound()


func handle_level_changed(current_level_name: String):
	var next_level_name: String
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/DesertLevel.tscn")
	#get_tree().change_scene_to_file("res://src/scenes/scene_4/levels/"+ next_level_name +"Level.tscn")
	print_debug(current_level_name)
	next_level_name = current_level_name
			
	print_debug(next_level_name)
	next_level = load("res://src/scenes/scene_levels/level_"+ next_level_name +"/level.tscn").instantiate()
	#next_level = load("res://src/scenes/levels/"+ next_level_name +"Level.tscn").instantiate()
	add_child(next_level)
	next_level.connect("level_changed", Callable(self, "handle_level_changed"))
	next_level.play_loaded_sound()
	#transfer_data_between_scenes(current_level, next_level)


func transfer_data_between_scenes(old_scene: CanvasLayer, new_scene: CanvasLayer):
	if old_scene and new_scene:
		new_scene.load_level_parameters(old_scene.level_parameters)

func play_loaded_sound() -> void:
	print_debug('todo')
	#$LevelLoadedSound.play()
	#$ChangeSceneButton.disabled = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()

	
