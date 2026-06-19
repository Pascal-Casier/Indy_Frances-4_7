extends AnimatableBody3D

@onready var turrets: Node3D = $turrets


# Paramètres visibles dans l'inspecteur
@export var rotation_speed: float = 30.0  # en degrés par seconde
@export var clockwise: bool = true        # true = horaire, false = anti-horaire
@export_group("Cadence des tourelles")
@export_range(0.1, 5.0, 0.01, "suffix:s") var cadence_min: float = 0.8
@export_range(0.1, 5.0, 0.01, "suffix:s") var cadence_max: float = 1.2

func _ready() -> void:
	randomize()
	for c in turrets.get_children():
		if c.has_method("set_cadence"):
			c.set_cadence(randf_range(cadence_min, cadence_max))
		


func _process(delta: float) -> void:
	# Sens : horaire = angle négatif, anti-horaire = positif (axe Y Godot)
	var direction: float = -1.0 if clockwise else 1.0
	
	# rotate_y() attend des radians, on convertit et on multiplie par delta
	rotate_y(deg_to_rad(rotation_speed * direction * delta))
