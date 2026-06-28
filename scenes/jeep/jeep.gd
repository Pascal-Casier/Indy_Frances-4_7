extends Node3D
class_name Jeep

@onready var ball: RigidBody3D = $Ball
@onready var model: Node3D = $jeep
@onready var ray_cast_3d: RayCast3D = $jeep/RayCast3D
@onready var pivot: Marker3D = $Pivot
@onready var wheel_front_left: MeshInstance3D = $"jeep/wheel-front-left"
@onready var wheel_front_right: MeshInstance3D = $"jeep/wheel-front-right"
@onready var engine_sound: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var indiana_jones_fully_animated: Node3D = $jeep/IndianaJones_fully_animated
@onready var camera_jeep: Camera3D = $Pivot/Camera3D

var min_pitch = 0.8   # pitch au ralenti
var max_pitch = 2.2   # pitch à pleine vitesse
var max_speed = 20.0  # vitesse max estimée (à ajuster)

var speed_input = 0
var turn_input = 0
var acceleration = 30.0
var steering_angle = 20.0
var turn_speed = 3.0

var player_cam: Node3D = null
var player : CharacterBody3D = null
var is_driven := false

var is_boosted = false
var boost_timer = 0.0
var boost_force_value = 0.0

var sphere_offset = Vector3(0, -1, 0)

var current_yaw = 0.0
var camera_smoothness = 2.0

var wheel_left_base_y: float
var wheel_right_base_y: float

var body_tilt = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ray_cast_3d.add_exception(ball)
	ball.contact_monitor = true
	ball.max_contacts_reported = 10
	ball.body_entered.connect(_on_ball_hit)
	# Sauvegarde la rotation initiale des roues
	wheel_left_base_y = wheel_front_left.rotation.y
	wheel_right_base_y = wheel_front_right.rotation.y



func _on_ball_hit(body: Node) -> void:
	if body.has_method("break_barrel"):
		var impact = ball.linear_velocity.length()
		print("impact : ", impact)
		if impact > 5.0:
			body.break_barrel()
		

func _process(delta: float) -> void:
	speed_input = (
		Input.get_action_strength("ui_up") -
		Input.get_action_strength("ui_down")
	) * acceleration

	turn_input = (
		Input.get_action_strength("ui_left") -
		Input.get_action_strength("ui_right")
	) * deg_to_rad(steering_angle)
	
	# Applique le turn par-dessus la rotation de base
	wheel_front_left.rotation.y = wheel_left_base_y + turn_input
	wheel_front_right.rotation.y = wheel_right_base_y + turn_input
	#wheel_front_left.rotation.y = turn_input
	#wheel_front_right.rotation.y = turn_input
	
	
func _physics_process(delta: float) -> void:
	model.global_position = ball.global_position + sphere_offset
	pivot.global_position = ball.global_position
	current_yaw = lerp_angle(current_yaw, model.rotation.y, delta * camera_smoothness)
	pivot.rotation.y = current_yaw
	
	if not ray_cast_3d.is_colliding():
		return
	
	var speed_factor = clamp(ball.linear_velocity.length() / 3.0, 0.0, 1.0)
	var direction_sign = sign(speed_input) if abs(speed_input) > 0.1 else sign(-model.global_transform.basis.z.dot(ball.linear_velocity))
	var current_basis = model.global_transform.basis
	var rotated_basis = current_basis.rotated(current_basis.y, turn_input * speed_factor * direction_sign)
	var smoothed_basis = current_basis.slerp(rotated_basis, delta * turn_speed)
	model.global_basis = smoothed_basis.orthonormalized()
	
	var direction = -model.global_transform.basis.z
	var total_force = speed_input

	# Applique le boost si actif
	if is_boosted:
		boost_timer -= delta
		total_force += boost_force_value
		if boost_timer <= 0.0:
			is_boosted = false

	ball.apply_central_force(direction * total_force)
	
	var t = -turn_input * ball.linear_velocity.length() / body_tilt
	model.rotation.z = lerp(model.rotation.z, t, 10 * delta)
	
	var normal = ray_cast_3d.get_collision_normal().normalized()
	var new_transform = align_with_y(model.global_transform, normal).orthonormalized()
	var interp = model.global_transform.interpolate_with(new_transform, delta * 10.0)
	var scale = model.global_transform.basis.get_scale()
	interp.basis = interp.basis.orthonormalized().scaled(scale)
	model.global_transform = interp

	# Son moteur
	if not engine_sound.playing:
		engine_sound.play()
	var current_speed = ball.linear_velocity.length()
	engine_sound.pitch_scale = lerp(min_pitch, max_pitch, clamp(current_speed / max_speed, 0.0, 1.0))


func apply_speed_boost(force: float, duration: float) -> void:
	boost_force_value = force
	boost_timer = duration
	is_boosted = true

func align_with_y(transform: Transform3D, new_y: Vector3) -> Transform3D:
	transform.basis.y = new_y
	transform.basis.x = -transform.basis.z.cross(new_y).normalized()
	transform.basis.z = transform.basis.x.cross(new_y).normalized()
	return transform
