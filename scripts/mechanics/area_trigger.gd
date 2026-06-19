extends Area3D

@export var door_nbr : int = -1
@export var desactivate : bool = true
@export var visivel : bool = true

func _ready() -> void:
	if !visivel:
		$MeshInstance3D.hide()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.emit_open_door_gate(door_nbr)
	if desactivate:
		set_deferred("monitoring", false)


func _on_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.
