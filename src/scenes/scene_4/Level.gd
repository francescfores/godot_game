class_name LevelList extends CanvasLayer


signal level_changed(level_name)

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
	emit_signal("level_changed", level_name)


func _on_ClickButton_pressed() -> void:
	set_clicks(level_parameters.clicks + 1)


# Esta es la lista de niveles, cada nivel tiene un nombre y una imagen
var levels = [
	{"name": "Level 1", "image_path": "res://assets/images/platformer.webp"},
	{"name": "Level 2", "image_path": "res://assets/images/platformer.webp"},
	{"name": "Level 3", "image_path": "res://assets/images/platformer.webp"},
	{"name": "Level 4", "image_path": "res://assets/images/platformer.webp"}
]

func _ready():
	var vbox_container =  $CenterContainer/HBoxContainer
	if not vbox_container:
		print("Error: CenterContainer/VBoxContainer not found!")
		return
		
	for level in levels:
		var level_box = create_level_box(level["name"], level["image_path"])
		vbox_container.add_child(level_box)

func create_level_box(level_name: String, image_path: String) -> VBoxContainer:
	var level_vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = level_name
	level_vbox.add_child(label)
	
	var texture_rect = TextureRect.new()
	var texture = load(image_path)
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	level_vbox.add_child(texture_rect)
	
	return level_vbox

