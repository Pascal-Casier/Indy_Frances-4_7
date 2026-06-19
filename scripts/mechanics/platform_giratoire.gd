extends AnimatableBody3D


@export var vitesse_rotation: float = 90.0
@export var axe_rotation: Vector3 = Vector3.UP

func _process(delta):
	rotate(axe_rotation.normalized(), deg_to_rad(vitesse_rotation) * delta)
