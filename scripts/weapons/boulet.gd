extends RigidBody3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()

func move() -> void:
	apply_central_force(Vector3.FORWARD * 800)
