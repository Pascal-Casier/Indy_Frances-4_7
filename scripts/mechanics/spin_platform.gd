extends CharacterBody3D

@export var speed : int = 45


func _physics_process(delta: float) -> void:
	rotation_degrees.y += speed * delta
