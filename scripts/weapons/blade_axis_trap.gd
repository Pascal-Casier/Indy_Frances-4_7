extends Node3D

@onready var blade_axis: Node3D = $blade_axis1

var rotation_tween: Tween

func _ready() -> void:
	start_infinite_rotation()

func start_infinite_rotation() -> void:
	if rotation_tween and rotation_tween.is_valid():
		rotation_tween.kill()

	rotation_tween = create_tween()

	# Étape 1 : Rotation de 180° autour de l'axe Y (PI radians)
	rotation_tween.tween_property(blade_axis, "rotation:y", rotation.y + PI, 1.0)\
		.set_trans(Tween.TRANS_LINEAR)

	# Étape 2 : Deuxième rotation de 180° pour finir le tour (TAU radians)
	rotation_tween.tween_property(blade_axis, "rotation:y", rotation.y + TAU, 1.0)\
		.set_trans(Tween.TRANS_LINEAR)

	# Relance la boucle une fois les deux étapes terminées
	rotation_tween.finished.connect(start_infinite_rotation, CONNECT_ONE_SHOT)
