extends AnimatableBody3D

@export var descent_distance: float = 5.0
@export var move_speed: float = 3.0
@export var mass_threshold: float = 0.5
@export var player_mass: float = 1.0
@export var balance_threshold: float = 0.1
@export var starts_raised: bool = true
@export var partner_platform: NodePath = NodePath("")

@onready var detection_area: Area3D = $DetectionArea
@onready var pulley_sound: AudioStreamPlayer3D = $PulleySound

var high_position: Vector3
var low_position: Vector3
var target_position: Vector3
var partner: AnimatableBody3D = null
var is_moving: bool = false

func _ready():
	high_position = global_position
	low_position = high_position - Vector3(0, descent_distance, 0)
	
	if not starts_raised:
		global_position = low_position
	
	if not partner_platform.is_empty():
		var node = get_node_or_null(partner_platform)
		if node is AnimatableBody3D:
			partner = node
	
	target_position = high_position if starts_raised else low_position

func get_detected_mass() -> float:
	var total: float = 0.0
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("Player"):
			total += player_mass
		elif body is RigidBody3D:
			total += body.mass
	return total

func _physics_process(delta: float):
	var my_mass = get_detected_mass()
	var new_target: Vector3 = target_position
	
	if partner:
		var partner_mass = partner.get_detected_mass()
		var diff = my_mass - partner_mass
		
		if abs(diff) < balance_threshold:
			new_target = global_position  # Reste en place
		elif diff > 0:
			new_target = low_position
		else:
			new_target = high_position
	else:
		new_target = low_position if my_mass > mass_threshold else high_position
	
	# Déterminer si on doit bouger
	var distance_to_target = global_position.distance_to(new_target)
	var should_be_moving = distance_to_target > 0.01  # Seuil de mouvement
	
	# Mise à jour de la target
	target_position = new_target
	
	# Mouvement fluide
	if should_be_moving:
		global_position = global_position.move_toward(target_position, move_speed * delta)
	
	# Gestion du son avec hysteresis
	if should_be_moving and not is_moving:
		is_moving = true
		if pulley_sound and pulley_sound.stream:
			pulley_sound.play()
	elif not should_be_moving and is_moving:
		is_moving = false
		if pulley_sound and pulley_sound.playing:
			pulley_sound.stop()
