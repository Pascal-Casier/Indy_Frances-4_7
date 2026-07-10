extends Area3D

@export var boost_force := 12
@export var boost_duration := 1.5


func _on_body_entered(body):
	if body.get_parent() is Jeep2:
		body.get_parent().apply_speed_boost(boost_force, boost_duration)
