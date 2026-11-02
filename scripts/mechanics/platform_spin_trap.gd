extends Node3D

@export var speed : float = 100.00
@onready var spinner: MeshInstance3D = $obstacle_4_001


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spinner.rotation_degrees.y += speed * delta
