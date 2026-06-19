extends Node3D


func _on_spike_roller_gltf_body_entered(body):
	if body.is_in_group("Player"):
		body.damage_received()
