extends Node3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
var can_damage : bool = false

func _process(_delta: float) -> void:
	if can_damage:
		var collider = ray_cast_3d.get_collider()
		if collider and 'hit' in collider:
			collider.hit()
