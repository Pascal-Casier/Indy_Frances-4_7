extends Node3D

@export var vitesse_rotation := 0.5
@export var rayon := 5.0
@export var door_nbr : int = -1
@export var tourne_au_debut := true  # ← nouveau

var is_open := false
@onready var axe = $Axe
@onready var plateformes = [
	$Axe/Bras1/Plateforme1,
	$Axe/Bras2/Plateforme2,
	$Axe/Bras3/Plateforme3
]

func _ready():
	$Axe/Bras1.position = Vector3(rayon, 0, 0)
	$Axe/Bras2.position = Vector3(
		rayon * cos(deg_to_rad(120)),
		rayon * sin(deg_to_rad(120)),
		0
	)
	$Axe/Bras3.position = Vector3(
		rayon * cos(deg_to_rad(240)),
		rayon * sin(deg_to_rad(240)),
		0
	)
	
	# Initialiser les rotations même si le process est désactivé
	for plateforme in plateformes:
		if plateforme is AnimatableBody3D:
			plateforme.global_rotation = Vector3.ZERO

	Global.open_door_gate.connect(open_door)
	set_physics_process(tourne_au_debut)

func _physics_process(delta):
	axe.rotate_z(vitesse_rotation * delta)
	for plateforme in plateformes:
		if plateforme is AnimatableBody3D:
			plateforme.global_rotation = Vector3.ZERO

func open_door(nbr):
	if nbr == door_nbr and !is_open:
		set_physics_process(true)
		is_open = true
