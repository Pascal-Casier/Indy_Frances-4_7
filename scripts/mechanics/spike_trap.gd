extends Area3D

@onready var animation_player = $AnimationPlayer as AnimationPlayer
@export var launch_force := 1.3

func _on_body_entered(body):
	if body.is_in_group("Player"):
		$AudioStreamPlayer.play()
		animation_player.play("SpikeTrap_Activate")
		body.launch_from_catapult(launch_force)
		body.damage_received()
	elif body.is_in_group("Enemy"):
		$AudioStreamPlayer.play()
		animation_player.play("SpikeTrap_Activate")
		body.die()
