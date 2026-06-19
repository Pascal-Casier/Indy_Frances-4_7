extends StaticBody3D


@export var blow_force : int = 2
@onready var destruction: Destruction = $Destruction

func destroy(force) -> void:
	destruction.destroy(force)
