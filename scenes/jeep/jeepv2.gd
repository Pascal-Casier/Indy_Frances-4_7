extends Node3D
class_name Jeep2

@onready var ball: RigidBody3D = $Ball
@onready var model: Node3D = $jeep
@onready var ray_cast_3d: RayCast3D = $jeep/RayCast3D
@onready var pivot: Marker3D = $Pivot
@onready var wheel_front_left: MeshInstance3D = $"jeep/wheel-front-left"
@onready var wheel_front_right: MeshInstance3D = $"jeep/wheel-front-right"
@onready var engine_sound: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var indiana_jones_fully_animated: Node3D = $jeep/IndianaJones_fully_animated
@onready var camera_jeep: Camera3D = $Pivot/Camera3D

# ============================================================
# PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur Godot)
# ============================================================

@export_group("Moteur")
@export var acceleration: float = 30.0        ## Force de propulsion appliquée à la balle
@export var max_speed: float = 20.0           ## Vitesse max estimée (pour les ratios)

@export_group("Direction")
@export var steering_angle: float = 20.0      ## Angle de braquage max à basse vitesse (degrés)
@export var steering_angle_min: float = 8.0   ## Angle de braquage max à haute vitesse (degrés)
@export var turn_speed: float = 3.0           ## Vitesse de rotation du modèle

@export_group("Physique")
@export var grip_strength: float = 15.0       ## Résistance au glissement latéral
@export var brake_drag: float = 2.0           ## Décélération naturelle au relâchement

@export_group("Carrosserie")
@export var sphere_offset: Vector3 = Vector3(0, -1, 0)  ## Décalage du modèle par rapport à la balle
@export var body_tilt_strength: float = 0.3   ## Intensité du penchement en virage

@export_group("Caméra")
@export var camera_smoothness: float = 6.0    ## Réactivité du suivi de la caméra
@export var camera_lag_amount: float = 1.5    ## Recul de la caméra à l'accélération
@export var fov_min: float = 70.0             ## FOV à l'arrêt
@export var fov_max: float = 85.0             ## FOV à pleine vitesse

@export_group("Son moteur")
@export var min_pitch: float = 0.8            ## Pitch au ralenti
@export var max_pitch: float = 2.2            ## Pitch à pleine vitesse
@export var throttle_pitch_boost: float = 0.3 ## Réactivité du pitch à l'accélérateur

# ============================================================
# VARIABLES INTERNES (non exportées)
# ============================================================

var speed_input: float = 0.0
var turn_input: float = 0.0

var player_cam: Node3D = null
var player: CharacterBody3D = null
var is_driven := false

var is_boosted: bool = false
var boost_timer: float = 0.0
var boost_force_value: float = 0.0

var current_yaw: float = 0.0
var camera_base_z: float = 3.0

var wheel_left_base_y: float
var wheel_right_base_y: float


# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
	ray_cast_3d.add_exception(ball)
	ball.contact_monitor = true
	ball.max_contacts_reported = 10
	ball.body_entered.connect(_on_ball_hit)
	wheel_left_base_y = wheel_front_left.rotation.y
	wheel_right_base_y = wheel_front_right.rotation.y
	camera_base_z = camera_jeep.position.z


func _on_ball_hit(body: Node) -> void:
	if body.has_method("break_barrel"):
		var impact = ball.linear_velocity.length()
		print("impact : ", impact)
		if impact > 5.0:
			body.break_barrel()


# ============================================================
# BOUCLE PRINCIPALE
# ============================================================

func _process(delta: float) -> void:
	var speed_ratio = clamp(ball.linear_velocity.length() / max_speed, 0.0, 1.0)

	# Lecture des inputs
	speed_input = (
		Input.get_action_strength("ui_up") -
		Input.get_action_strength("ui_down")
	) * acceleration

	# Braquage dynamique : angle réduit à haute vitesse
	var dynamic_steer = deg_to_rad(lerp(steering_angle, steering_angle_min, speed_ratio))
	turn_input = (
		Input.get_action_strength("ui_left") -
		Input.get_action_strength("ui_right")
	) * dynamic_steer

	# Rotation visuelle des roues avant
	wheel_front_left.rotation.y = wheel_left_base_y + turn_input
	wheel_front_right.rotation.y = wheel_right_base_y + turn_input

	# FOV dynamique : s'élargit à haute vitesse
	camera_jeep.fov = lerp(camera_jeep.fov, lerp(fov_min, fov_max, speed_ratio), delta * 3.0)

	# Camera lag : recule légèrement à l'accélération
	var throttle_ratio = speed_input / acceleration
	var cam_target_z = camera_base_z + lerp(0.0, camera_lag_amount, clamp(throttle_ratio, 0.0, 1.0))
	camera_jeep.position.z = lerp(camera_jeep.position.z, cam_target_z, delta * 5.0)


func _physics_process(delta: float) -> void:
	model.global_position = ball.global_position + sphere_offset
	pivot.global_position = ball.global_position
	current_yaw = lerp_angle(current_yaw, model.rotation.y, delta * camera_smoothness)
	pivot.rotation.y = current_yaw

	if not ray_cast_3d.is_colliding():
		return

	var current_speed = ball.linear_velocity.length()
	var speed_ratio = clamp(current_speed / max_speed, 0.0, 1.0)

	# --- Rotation du modèle ---
	var speed_factor = clamp(current_speed / 3.0, 0.0, 1.0)
	var direction_sign = sign(speed_input) if abs(speed_input) > 0.1 else sign(-model.global_transform.basis.z.dot(ball.linear_velocity))
	var current_basis = model.global_transform.basis
	var rotated_basis = current_basis.rotated(current_basis.y, turn_input * speed_factor * direction_sign)
	var smoothed_basis = current_basis.slerp(rotated_basis, delta * turn_speed)
	model.global_basis = smoothed_basis.orthonormalized()

	# --- Force de propulsion ---
	var direction = -model.global_transform.basis.z
	var total_force = speed_input

	if is_boosted:
		boost_timer -= delta
		total_force += boost_force_value
		if boost_timer <= 0.0:
			is_boosted = false

	ball.apply_central_force(direction * total_force)

	# Grip latéral : réduit le glissement sur les côtés
	var right = model.global_transform.basis.x
	var lateral_velocity = right.dot(ball.linear_velocity)
	ball.apply_central_force(-right * lateral_velocity * grip_strength)

	# Freinage naturel quand on relâche l'accélérateur
	if abs(speed_input) < 0.1:
		ball.linear_velocity = ball.linear_velocity.lerp(Vector3.ZERO, delta * brake_drag)

	# Body tilt : penche la carrosserie en virage
	var steer_normalized = turn_input / deg_to_rad(steering_angle)
	var tilt_target = -steer_normalized * speed_ratio * body_tilt_strength
	model.rotation.z = lerp(model.rotation.z, tilt_target, 8.0 * delta)

	# --- Alignement sur le sol ---
	var normal = ray_cast_3d.get_collision_normal().normalized()
	var new_transform = align_with_y(model.global_transform, normal).orthonormalized()
	var interp = model.global_transform.interpolate_with(new_transform, delta * 10.0)
	var scale = model.global_transform.basis.get_scale()
	interp.basis = interp.basis.orthonormalized().scaled(scale)
	model.global_transform = interp

	# Son moteur : réactif à la vitesse ET à l'accélérateur
	if not engine_sound.playing:
		engine_sound.play()
	var throttle_boost = abs(speed_input / acceleration) * throttle_pitch_boost
	engine_sound.pitch_scale = lerp(min_pitch, max_pitch, clamp(current_speed / max_speed, 0.0, 1.0)) + throttle_boost


# ============================================================
# FONCTIONS UTILITAIRES
# ============================================================

func apply_speed_boost(force: float, duration: float) -> void:
	boost_force_value = force
	boost_timer = duration
	is_boosted = true


func align_with_y(transform: Transform3D, new_y: Vector3) -> Transform3D:
	transform.basis.y = new_y
	transform.basis.x = -transform.basis.z.cross(new_y).normalized()
	transform.basis.z = transform.basis.x.cross(new_y).normalized()
	return transform
