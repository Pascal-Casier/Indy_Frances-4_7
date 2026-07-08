extends Area3D

@export var total_time : float

func _on_body_entered(body: Node3D) -> void:
	if body.get_parent() is Jeep2:
		body.get_parent().start_timer(total_time)
