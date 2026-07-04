extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body.get_parent() is Jeep2:
		body.get_parent().mud_effect(true)


func _on_body_exited(body: Node3D) -> void:
	if body.get_parent() is Jeep2:
		body.get_parent().mud_effect(false)
