extends Area2D

@export var escena := ""

func _on_body_entered(body):
	if body.name == "Player":
		#get_tree().change_scene_to_file("res://src/scenes/scene_"+escena+"/scene_"+escena+".tscn")
		get_tree().change_scene_to_file("res://src/scenes/scene_4/switch_level.tscn")
