extends Node3D

@export var door_nbr := -1
@export var destination_pos : Vector3i
var initial_pos : Vector3i


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.open_door_gate.connect(lift)
	initial_pos = position
	
func lift(doornb):
	if doornb == door_nbr:
		pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		pass
