extends Node3D

@export_enum("down", "down_only") var anim_name = "down"



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%AudioStreamClic.play()
		%AnimationPlayer.play(anim_name)
		

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_deferred("monitoring", true)
		
