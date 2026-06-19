extends Area3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _on_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("fade")
		await get_tree().create_timer(1).timeout
		#body.global_transform.origin = Vector3(0,4,0)
		CheckpointManager.respawn_player()
	elif body.is_in_group("Enemy"):
		body.die()
