extends VBoxContainer

signal level_selected(level_name)

# Función para establecer la propiedad meta
func set_level_name(level_name: String) -> void:
	set_meta("level_name", level_name)

func _ready():
	connect("gui_input", Callable(self, "_on_gui_input"))
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var level_name = get_meta("level_name")
		if level_name != null:
			emit_signal("level_selected", level_name)
		else:
			print("Error: level_name meta property is not set")


