class_name Scene extends CanvasLayer


signal level_changed(next_name)

@export  var next_name = ""
@export  var level_name = ""

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



func _on_change_scene_button_2_pressed():
	$ButtonClickedSound.play()
	$ChangeSceneButton.disabled = true
	next_name='Desert'
	emit_signal("level_changed", next_name)
