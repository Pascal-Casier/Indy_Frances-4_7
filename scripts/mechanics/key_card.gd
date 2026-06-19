extends Node3D

var speed := 3

func _process(delta: float) -> void:
	%Pickup_KeyCard.rotation.y += speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not Global.has_keycard:
		%AnimationPlayer.play("pickup")
		%AudioStreamPlayer.play()
		%Area3D.set_deferred("monitoring", false)
		Global.has_keycard = true
		Global.emit_signal("on_keycard_found")
		
		
func _on_audio_stream_player_finished() -> void:
	queue_free()
