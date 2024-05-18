class_name LevelsList extends CanvasLayer


signal level_changed(next_name)

@export  var next_name = ""
@export  var level_name = "level"

var level_parameters := {
	"clicks": 0
}


func load_level_parameters(new_level_parameters: Dictionary):
	level_parameters = new_level_parameters
	$ClickLabel.text = "Clicks: " + str(level_parameters.clicks)


func play_loaded_sound() -> void:
	$LevelLoadedSound.play()
	$ChangeSceneButton.disabled = false


func cleanup():
	if $ButtonClickedSound.playing:
		await $ButtonClickedSound.finished
	queue_free()


func set_clicks(new_click_amount: int):
	level_parameters.clicks = new_click_amount
	$ClickLabel.text = "Clicks: " + str(level_parameters.clicks)


func _on_ChangeSceneButton_pressed() -> void:
	$ButtonClickedSound.play()
	$ChangeSceneButton.disabled = true
	emit_signal("level_changed", next_name)


func _on_ClickButton_pressed() -> void:
	set_clicks(level_parameters.clicks + 1)


# Esta es la lista de niveles, cada nivel tiene un nombre y una imagen
var levels = [
	{"name": "Level 1", "image_path": "res://assets/tiles/catastrophi_tiles.png"},
	{"name": "Level 2", "image_path": "res://assets/images/platformer.webp"},
	{"name": "Level 3", "image_path": "res://assets/images/platformer.webp"},
	{"name": "Level 4", "image_path": "res://assets/images/platformer.webp"}
]

func _ready():
	var hbox_container = $CenterContainer/HBoxContainer
	if not hbox_container:
		print("Error: CenterContainer/HBoxContainer not found!")
		return
		
	var vbox_template =  $CenterContainer/HBoxContainer/VBoxContainer
	if not vbox_template:
		print("Error: CenterContainer/VBoxContainer not found!")
		return
	vbox_template.visible = false

	for level in levels:
		create_level_box(level["name"], level["image_path"], hbox_container, vbox_template)

func create_level_box(level_name: String, image_path: String, hbox_container: HBoxContainer, vbox_template: VBoxContainer) -> void:
	var new_vbox = vbox_template.duplicate()  # Clonar el VBoxContainer template
	
	# Configurar el Label del nuevo VBoxContainer
	var label = new_vbox.get_node("Label")
	if label:
		label.text = level_name
	else:
		print("Error: Label node not found in VBoxContainer template!")
	
	# Configurar la imagen del nuevo VBoxContainer
	var image = new_vbox.get_node("TextureRect")
	if image:
		var texture = load(image_path)
		image.texture = texture
	else:
		print("Error: Image node not found in VBoxContainer template!")
	
	hbox_container.add_child(new_vbox)  # Agregar el nuevo VBoxContainer al HBoxContainer
	# Hacer visible el nuevo VBoxContainer duplicado
	new_vbox.visible = true
