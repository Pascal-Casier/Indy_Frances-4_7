extends Node3D

@export var speed : float = 1.0

func _ready() -> void:
	$AnimationPlayer.speed_scale = speed


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
