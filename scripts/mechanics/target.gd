extends Node3D

@export var opening_door : bool = true
@export var door_number : int = 1

func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Pickeable"):
		body.queue_free()
		$AudioStreamPlayer.play()
		%AnimationPlayer.play("bullseye")
		if opening_door:
			Global.emit_open_door_gate(door_number)
		
