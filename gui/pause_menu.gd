class_name PauseMenu extends Control


@export var fade_in_duration := 0
@export var fade_out_duration := 0

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/ResumeButton") as Button
@onready var coins_counter := $ColorRect/CoinsCounter as CoinsCounter

@export var scene := "2"

func _ready() -> void:
	hide()


func close() -> void:
		print_debug('open')
		get_tree().paused = false
		var tween := create_tween()
		tween.tween_property(
			self,
			^"modulate:a",
			0.0,
			fade_out_duration
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(
			center_cont,
			^"anchor_bottom",
			0.5,
			fade_out_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_callback(hide)


func open() -> void:
	print_debug('open')
	show()
	resume_button.grab_focus()

	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	var tween := create_tween()
	tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_coin_collected() -> void:
	coins_counter.collect_coin()


func _on_resume_button_pressed() -> void:
	close()


func _on_singleplayer_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		#get_tree().change_scene_to_file("res://src/game_singleplayer.tscn")
		get_tree().change_scene_to_file("res://src/scenes/scene_levels/level_"+ scene +"/level.tscn")

func _on_splitscreen_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		#get_tree().change_scene_to_file("res://src/game_splitscreen.tscn")
		get_tree().change_scene_to_file("res://src/scenes/scene_levels/level_"+ scene +"/level_spleetscreen.tscn")
func _on_quit_button_pressed() -> void:
	if visible:
		print_debug('quit')
		get_tree().quit()


func _on_titlescreen_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		#get_tree().change_scene_to_file("res://src/game_splitscreen.tscn")
		get_tree().change_scene_to_file("res://src/scenes/main.tscn")
 


func _on_player_coin_collected():
	pass # Replace with function body.
