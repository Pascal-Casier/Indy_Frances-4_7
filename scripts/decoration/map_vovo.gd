extends Area3D

var player : CharacterBody3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = null
