class_name TitleScreen extends Control


@export var fade_in_duration := 0
@export var fade_out_duration := 0

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/ResumeButton") as Button
@onready var coins_counter := $ColorRect/CoinsCounter as CoinsCounter

@export var scene := ""

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://src/scenes/scene_"+scene+"/scene_"+scene+".tscn")

func _ready() -> void:
	print_debug('open')
	#hide()


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
	#get_tree().change_scene_to_file("res://src/scenes/scene_"+scene+"/scene_"+scene+".tscn")
			#get_tree().change_scene_to_file("res://src/scenes/main.tscn")
			get_tree().change_scene_to_file("res://src/scenes/scene_levels/level_1/level.tscn")
	#close()


func _on_singleplayer_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://src/game_singleplayer.tscn")


func _on_splitscreen_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://src/game_splitscreen.tscn")


func _on_quit_button_pressed() -> void:
	if visible:
		print_debug('quit')
		get_tree().quit()
