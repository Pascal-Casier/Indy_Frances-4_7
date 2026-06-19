extends Node3D
class_name WheelTargets

@export var rotation_speed : float = 1.0
@onready var wheel_targets: Node3D = %wheel_targets


func _physics_process(delta: float) -> void:
	wheel_targets.rotation_degrees.y += rotation_speed * 10 * delta
