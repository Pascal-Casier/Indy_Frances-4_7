extends Node3D
class_name Jeep2

@onready var ball: RigidBody3D = $Ball
@onready var model: Node3D = $jeep
@onready var ray_cast_3d: RayCast3D = $jeep/RayCast3D
@onready var pivot: Marker3D = $Pivot
@onready var wheel_front_left: MeshInstance3D = $"jeep/wheel-front-left"
@onready var wheel_front_right: MeshInstance3D = $"jeep/wheel-front-right"
@onready var engine_sound: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var camera_jeep: Camera3D = $Pivot/Camera3D
@onready var skid_marks_left: GPUParticles3D = $"jeep/wheel-back-left/GPUParticles3D"
@onready var skid_marks_right: GPUParticles3D = $"jeep/wheel-back-right/GPUParticles3D2"
@onready var smoke1: GPUParticles3D = $jeep/GPUParticles3D
@onready var smoke2: GPUParticles3D = $jeep/GPUParticles3D2
@onready var speedlbl: Label = %speedlbl
@onready var lesma: TextureRect = %lesma
@onready var timer_node: Timer = %Timer
@onready var time_lbl: Label = %TimeLbl
@onready var audio_brake: AudioStreamPlayer3D = $AudioStreamBrake
var turbo_bar: ProgressBar                # Jauge de turbo (optionnelle, voir _ready)
var turbo_ready_sound: AudioStreamPlayer  # Son "prêt" (optionnel)
var turbo_particles: GPUParticles3D       # Effet de flamme/étincelles au déclenchement (optionnel)


var drift_lateral_threshold = 2.0   # vitesse latérale mini pour considérer que ça dérape
var drift_min_speed = 3.0           # vitesse totale mini pour émettre
var grip_multiplier = 1.0
var default_friction: float
# ============================================================
# PARAMÈTRES EXPORTÉS (modifiables dans l'inspecteur Godot)
# ============================================================

@export_group("Moteur")
@export var acceleration: float = 30.0        ## Force de propulsion appliquée à la balle
@export var max_speed: float = 20.0           ## Vitesse max estimée (pour les ratios)

@export_group("Direction")
@export var steering_angle: float = 35.0      ## Angle de braquage max à basse vitesse (degrés)
@export var steering_angle_min: float = 15.0   ## Angle de braquage max à haute vitesse (degrés)
@export var turn_speed: float = 3.0           ## Vitesse de rotation du modèle

@export_group("Physique")
@export var grip_strength: float = 3.0       ## Résistance au glissement latéral
@export var brake_drag: float = 0.0           ## Décélération naturelle au relâchement

@export_group("Carrosserie")
@export var sphere_offset: Vector3 = Vector3(0, -1, 0)  ## Décalage du modèle par rapport à la balle
@export var body_tilt_strength: float = 0.6   ## Intensité du penchement en virage

@export_group("Caméra")
@export var camera_smoothness: float = 3.0    ## Réactivité du suivi de la caméra
@export var camera_lag_amount: float = 1.5    ## Recul de la caméra à l'accélération
@export var fov_min: float = 70.0             ## FOV à l'arrêt
@export var fov_max: float = 75.0             ## FOV à pleine vitesse

@export_group("Son moteur")
@export var min_pitch: float = 0.8            ## Pitch au ralenti
@export var max_pitch: float = 2.2            ## Pitch à pleine vitesse
@export var throttle_pitch_boost: float = 0.3 ## Réactivité du pitch à l'accélérateur

@export_group("Turbo")
@export var turbo_fill_rate: float = 0.6      ## Vitesse de remplissage de la jauge (par seconde de drift)
@export var turbo_decay_rate: float = 0.4     ## Vitesse de vidage de la jauge quand on ne drift pas
@export var turbo_boost_force: float = 60.0   ## Force additionnelle appliquée pendant le turbo
@export var turbo_boost_duration: float = 1.2 ## Durée du turbo (secondes)
@export var turbo_auto_trigger: bool = false  ## true = se déclenche seul à 100%, false = il faut appuyer sur "boost"
@export var turbo_fov_kick: float = 8.0       ## Degrés de FOV ajoutés pendant le boost (effet "vitesse")
@export var turbo_shake_strength: float = 0.03 ## Intensité du tremblement caméra pendant le boost

# ============================================================
# VARIABLES INTERNES (non exportées)
# ============================================================

var speed_input: float = 0.0
var turn_input: float = 0.0

var is_driven := false

var is_boosted: bool = false
var boost_timer: float = 0.0
var boost_force_value: float = 0.0

var current_yaw: float = 0.0
var camera_base_z: float = 3.0

var wheel_left_base_y: float
var wheel_right_base_y: float

var penalty_multiplier: float = 1.0
var penalty_timer: float = 0.0

var time_left : float

var default_damp: float          # linear_damp de base de la balle, capturé au _ready()
var mud_zone_count: int = 0      # nombre de zones de boue actives (chevauchement géré)
var hit_stack: int = 0           # nombre de "dégâts" empilés (heal() les réinitialise tous)

var turbo_gauge: float = 0.0     # 0.0 (vide) à 1.0 (pleine)
var turbo_ready: bool = false    # true dès que la jauge atteint 1.0
var was_drifting: bool = false   # état du drift à la frame précédente (pour détecter la fin du drift)

# ============================================================
# INITIALISATION
# ============================================================

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ray_cast_3d.add_exception(ball)
	ball.contact_monitor = true
	ball.max_contacts_reported = 10
	ball.body_entered.connect(_on_ball_hit)
	wheel_left_base_y = wheel_front_left.rotation.y
	wheel_right_base_y = wheel_front_right.rotation.y
	camera_base_z = camera_jeep.position.z
	if ball.physics_material_override == null:
		ball.physics_material_override = PhysicsMaterial.new()
	default_friction = ball.physics_material_override.friction
	default_damp = ball.linear_damp

	# Nœuds optionnels liés au turbo : on vérifie leur existence pour ne pas planter
	# si tu n'as pas encore créé ces nœuds dans la scène.
	if has_node("%TurboBar"):
		turbo_bar = get_node("%TurboBar")
	if has_node("%TurboReadySound"):
		turbo_ready_sound = get_node("%TurboReadySound")
	if has_node("%TurboParticles"):
		turbo_particles = get_node("%TurboParticles")

func _on_ball_hit(body: Node) -> void:
	if body.has_method("break_barrel"):
		var impact = ball.linear_velocity.length()
		if impact > 5.0:
			body.break_barrel()

func set_grip(multiplier: float, friction: float) -> void:
	grip_multiplier = multiplier
	ball.physics_material_override.friction = friction

func reset_grip() -> void:
	grip_multiplier = 1.0
	ball.physics_material_override.friction = default_friction

# ============================================================
# BOUCLE PRINCIPALE
# ============================================================

func _process(delta: float) -> void:
	# Tout ce qui reste ici est purement visuel/UI et peut dépendre du framerate sans problème.
	var speed_ratio = clamp(ball.linear_velocity.length() / max_speed, 0.0, 1.0)

	# Rotation visuelle des roues avant (turn_input est calculé dans _physics_process)
	wheel_front_left.rotation.y = wheel_left_base_y + turn_input
	wheel_front_right.rotation.y = wheel_right_base_y + turn_input

	# FOV dynamique : s'élargit à haute vitesse, avec un kick supplémentaire pendant le turbo
	var target_fov = lerp(fov_min, fov_max, speed_ratio)
	if is_boosted:
		target_fov += turbo_fov_kick
	camera_jeep.fov = lerp(camera_jeep.fov, target_fov, delta * 5.0)

	# Camera lag : recule légèrement à l'accélération
	var throttle_ratio = speed_input / acceleration if acceleration != 0.0 else 0.0
	var cam_target_z = camera_base_z + lerp(0.0, camera_lag_amount, clamp(throttle_ratio, 0.0, 1.0))
	camera_jeep.position.z = lerp(camera_jeep.position.z, cam_target_z, delta * 5.0)

	# Shake caméra pendant le boost : léger tremblement aléatoire qui décroît
	if is_boosted:
		var shake_ratio = clamp(boost_timer / turbo_boost_duration, 0.0, 1.0)
		camera_jeep.h_offset = randf_range(-1.0, 1.0) * turbo_shake_strength * shake_ratio
		camera_jeep.v_offset = randf_range(-1.0, 1.0) * turbo_shake_strength * shake_ratio
	else:
		camera_jeep.h_offset = lerp(camera_jeep.h_offset, 0.0, delta * 10.0)
		camera_jeep.v_offset = lerp(camera_jeep.v_offset, 0.0, delta * 10.0)

	speedlbl.text = "%d km/h" % int(get_speed_kmh())

	# Timer label
	time_lbl.text = "%.2f" % timer_node.time_left

	# Jauge de turbo : remplissage visuel + couleur quand prête
	if turbo_bar:
		turbo_bar.value = turbo_gauge * 100.0
		var bar_fill := turbo_bar.get("theme_override_styles/fill") as StyleBoxFlat
		if bar_fill:
			bar_fill.bg_color = Color.ORANGE if turbo_ready else Color.CYAN

func _physics_process(delta: float) -> void:
	model.global_position = ball.global_position + sphere_offset
	pivot.global_position = ball.global_position
	current_yaw = lerp_angle(current_yaw, model.rotation.y, delta * camera_smoothness)
	pivot.rotation.y = current_yaw

	var current_speed = ball.linear_velocity.length()
	var speed_ratio = clamp(current_speed / max_speed, 0.0, 1.0)

	# --- Lecture des inputs (déplacée ici : la physique doit lire les inputs
	# au même rythme qu'elle applique les forces, sinon le comportement dépend du framerate) ---

	# Gestion de la durée de la pénalité
	if penalty_timer > 0.0:
		penalty_timer -= delta
		if penalty_timer <= 0.0:
			penalty_multiplier = 1.0  # Réinitialisation automatique

	speed_input = (
		Input.get_action_strength("ui_up") -
		Input.get_action_strength("ui_down")
	) * acceleration * penalty_multiplier

	# Braquage dynamique : angle réduit à haute vitesse
	var dynamic_steer = deg_to_rad(lerp(steering_angle, steering_angle_min, speed_ratio))
	turn_input = (
		Input.get_action_strength("ui_left") -
		Input.get_action_strength("ui_right")
	) * dynamic_steer

	if not ray_cast_3d.is_colliding():
		return

	# --- Rotation du modèle ---
	var speed_factor = clamp(current_speed / 3.0, 0.0, 1.0)
	var direction_sign = sign(speed_input) if abs(speed_input) > 0.1 else sign(-model.global_transform.basis.z.dot(ball.linear_velocity))
	var current_basis = model.global_transform.basis
	var rotated_basis = current_basis.rotated(current_basis.y, turn_input * speed_factor * direction_sign * grip_multiplier)
	var smoothed_basis = current_basis.slerp(rotated_basis, delta * turn_speed)
	model.global_basis = smoothed_basis.orthonormalized()
	
	var forward = -model.global_transform.basis.z
	var right = model.global_transform.basis.x
	var velocity = ball.linear_velocity

	var _forward_speed = velocity.dot(forward)
	var lateral_speed = velocity.dot(right)
	var total_speed = velocity.length()

	var is_drifting = abs(lateral_speed) > drift_lateral_threshold and total_speed > drift_min_speed

	skid_marks_left.emitting = is_drifting
	smoke1.emitting = is_drifting
	skid_marks_right.emitting = is_drifting
	smoke2.emitting = is_drifting
	
	if is_drifting:
		audio_brake.play()
	else:
		audio_brake.stop()
	
	var slip_ratio = clamp(abs(lateral_speed) / 10.0, 0.0, 1.0)
	skid_marks_left.amount_ratio = slip_ratio
	skid_marks_right.amount_ratio = slip_ratio

	# --- Jauge de turbo (mini-turbo façon Mario Kart) ---
	# Se remplit tant qu'on drift, se vide sinon (sauf si déjà pleine et en attente du trigger).
	if is_drifting:
		turbo_gauge = clamp(turbo_gauge + turbo_fill_rate * delta, 0.0, 1.0)
	elif not turbo_ready:
		turbo_gauge = clamp(turbo_gauge - turbo_decay_rate * delta, 0.0, 1.0)

	if turbo_gauge >= 1.0 and not turbo_ready:
		turbo_ready = true
		if turbo_ready_sound:
			turbo_ready_sound.play()
		if turbo_auto_trigger:
			trigger_turbo()

	# Déclenchement manuel : soit on appuie sur "boost", soit le drift vient tout juste de se terminer
	# (transition is_drifting -> false détectée via was_drifting, pas un simple relâchement de la direction)
	if turbo_ready and not turbo_auto_trigger:
		var drift_just_ended = was_drifting and not is_drifting
		var boost_pressed = InputMap.has_action("boost") and Input.is_action_just_pressed("boost")
		if boost_pressed or drift_just_ended:
			trigger_turbo()
	was_drifting = is_drifting
	
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
	# grip_multiplier (piloté par set_grip/reset_grip, ex. boue/verglas) influence maintenant
	# aussi le grip latéral, pas seulement la rotation.
	var lateral_velocity = right.dot(ball.linear_velocity)
	ball.apply_central_force(-right * lateral_velocity * grip_strength * grip_multiplier)

	# Freinage naturel quand on relâche l'accélérateur
	if abs(speed_input) < 0.1:
		ball.linear_velocity = ball.linear_velocity.lerp(Vector3.ZERO, delta * brake_drag)

	# Body tilt : penche la carrosserie en virage
	var steer_normalized = turn_input / deg_to_rad(steering_angle) if steering_angle != 0.0 else 0.0
	var tilt_target = -steer_normalized * speed_ratio * body_tilt_strength
	model.rotation.z = lerp(model.rotation.z, tilt_target, 8.0 * delta)

	# --- Alignement sur le sol ---
	var normal = ray_cast_3d.get_collision_normal().normalized()
	var new_transform = align_with_y(model.global_transform, normal).orthonormalized()
	var interp = model.global_transform.interpolate_with(new_transform, delta * 10.0)
	var _scale = model.global_transform.basis.get_scale()
	interp.basis = interp.basis.orthonormalized().scaled(_scale)
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

func trigger_turbo() -> void:
	apply_speed_boost(turbo_boost_force, turbo_boost_duration)
	turbo_gauge = 0.0
	turbo_ready = false
	if turbo_particles:
		turbo_particles.restart()
		turbo_particles.emitting = true


func align_with_y(_transform: Transform3D, new_y: Vector3) -> Transform3D:
	_transform.basis.y = new_y
	_transform.basis.x = -_transform.basis.z.cross(new_y).normalized()
	_transform.basis.z = _transform.basis.x.cross(new_y).normalized()
	return _transform
	
func appliquer_penalite(multiplicateur: float, duree: float = 2.0) -> void:
	penalty_multiplier = multiplicateur
	penalty_timer = duree
	
func mud_effect(enabled: bool) -> void:
	# Compteur de zones actives : évite que deux zones de boue qui se chevauchent
	# ne déséquilibrent linear_damp (ex. entrer dans une 2e zone puis ressortir de la 1re).
	if enabled:
		mud_zone_count += 1
	else:
		mud_zone_count = max(0, mud_zone_count - 1)
	_update_linear_damp()

func hit() -> void:
	hit_stack += 1
	lesma.show()
	_update_linear_damp()

func heal() -> void:
	hit_stack = 0
	lesma.hide()
	_update_linear_damp()

# Recalcule linear_damp à partir de la base + des effets actifs, pour que boue et
# dégâts (hit/heal) puissent être actifs en même temps sans s'écraser l'un l'autre.
func _update_linear_damp() -> void:
	var mud_contribution = 3.9 if mud_zone_count > 0 else 0.0
	var hit_contribution = hit_stack * 0.5
	ball.linear_damp = default_damp + mud_contribution + hit_contribution
	
func get_speed() -> float:
	return ball.linear_velocity.length()

func get_speed_kmh() -> float:
	return ball.linear_velocity.length() * 3.6

func stop() -> void:
	engine_sound.stop()
	time_left = timer_node.time_left
	set_physics_process(false)
	set_process(false)
	audio_brake.stop()
	speedlbl.hide()
	time_lbl.hide()


func start_timer(total_time: float) -> void:
	timer_node.wait_time = total_time
	timer_node.start()
