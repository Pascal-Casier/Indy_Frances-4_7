extends Camera3D

@export var springarm : Node3D
@export var lerp_power : float = 6.0

func _process(delta: float) -> void:
	position = lerp(position, springarm.position, lerp_power * delta)
