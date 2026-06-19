extends Node3D

@export var launch_force := 2.0
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("eject")
		await get_tree().create_timer(0.1).timeout
		body.launch_from_catapult(launch_force)
		
