class_name Bullet extends RigidBody2D


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func destroy() -> void:
	animation_player.play(&"destroy")


func _on_body_entered(body: Node) -> void:
	if body is Enemy2:
		(body as Enemy2).destroy()
	 #if body is  EnemyBridge:
	 #	(body as EnemyBridge).destroy()
	 #if body is  EnemyDemon:
	 #	(body as EnemyDemon).destroy()
