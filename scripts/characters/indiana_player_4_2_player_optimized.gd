extends CharacterBody3D

@onready var interaction_raycast = $IndianaJones_Model_4_2/interactionRaycast
@onready var hand = $IndianaJones_Model_4_2/hand
@onready var throw_audio_stream_player = $ThrowAudioStreamPlayer
@onready var hurt_audio_stream_player = $HurtAudioStreamPlayer
@onready var wand = $"IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D2/1H_Wand"
@onready var hurt_overlay: TextureRect = $Hurt_overlay
@onready var parapente: Node3D = $IndianaJones_Model_4_2/Parapente
@onready var animation_tree: AnimationTree = $IndianaJones_Model_4_2/AnimationTree
@onready var sword_hit: Area3D = $IndianaJones_Model_4_2/indy/GeneralSkeleton/sword_hit
@onready var sword_ray_cast_3d: RayCast3D = $IndianaJones_Model_4_2/indy/GeneralSkeleton/SwordRayCast3D
@onready var rope_shaded: Area3D = %RopeShaded
@onready var camroot: Node3D = $camroot
@onready var model: Node3D = $IndianaJones_Model_4_2

##### shapecast ###############
@export var player_mass: float = 70.0  # Poids simulé (kg)

@onready var shapecast: ShapeCast3D = $ShapeCast3D  # Chemin vers ton ShapeCast3D


#####Grapin variables ##############
@onready var grapple_controller: Node = $GrappingController
var is_releasing_grapple := false
####################################
@export var has_found_whip := false
@export var throwing_force : int = 200
@export var arm3D_lenght := 6.0
var movement_speed := 0.0
@export var run_speed := 85
@export var walk_speed := 60
var acceleration := 6.0
@export var jump_magnitude := 12.0
var vertical_velocity := 0.0
var gravity := 28.0
var angular_acceleration := 7

var direction := Vector3.FORWARD
var strafe_dir := Vector3.ZERO
var strafe := Vector3.ZERO

var can_move := true : set = set_can_move

var jumping := false
var last_floor := true
var jump_available : bool = true
var jump_number := 0
@export var can_double_jump := false

var sprint_toggle := true
var sprinting := false

var is_in_ventilator := false

var aiming : bool = false

var sword_visible : bool = true

######## fall Damage mechanic ################
var old_vel : float = 0.0
@export var fall_damage_thresold = 20
var hurt_tween : Tween
##############################################

########### Coyote Timer #####################
var coyote_timer: Timer
@export var coyote_time_duration := 0.2
##############################################

########### Jump Buffering ###################
var jump_buffer_timer: Timer
@export var jump_buffer_duration := 0.15
##############################################


var push_force := 25.0
var push_factor := 0.0

var picked_object
var pull_power := 5

@onready var shoot_timer = $Shoot_Timer
var can_shoot := true
@onready var muzzle = %muzzle
var bullet = preload("res://scenes/mechanics/bullet_lighning.tscn")
var instance
var is_attacking := false
var tuto_visible := false

# OPTIMISATION: Cache pour l'AnimationTree
var anim_state_machine
var current_aim_state := "not_aiming"
var target_blend_amount := -1.0

func _ready():
	Global.on_pause_mode.connect(pausing)
	Global.has_sword.connect(show_sword)
	Global.lantern_off.connect(lanternoff)
	# OPTIMISATION: Connecter un signal pour la mort au lieu de vérifier à chaque frame
	Global.on_health_updated.connect(_on_health_changed)
	
	$camroot/h/v/SpringArm3D.spring_length = arm3D_lenght
	Global.health = 100
	Global.emit_health_update()
	
	# Create and configure the Coyote Timer in code
	coyote_timer = Timer.new()
	coyote_timer.name = "CoyoteTimer"
	coyote_timer.one_shot = true
	add_child(coyote_timer)

	# Create and configure the Jump Buffer Timer in code
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.name = "JumpBufferTimer"
	jump_buffer_timer.one_shot = true
	add_child(jump_buffer_timer)
	
	# OPTIMISATION: Cache le state machine
	if animation_tree:
		anim_state_machine = animation_tree.get("parameters/JumpStateMachine/playback")


func _input(event):
	if Global.mode == Global.GameMode.READING:
		return
	if not Global.input_allowed():
		return
		
	if sprint_toggle:
		if event.is_action_pressed("sprint"):
			sprinting = not sprinting
	else:
		sprinting = Input.is_action_pressed("sprint")
	
	if event.is_action_pressed("toggle_sprint"):
		sprint_toggle = not sprint_toggle
			
	if event.is_action_pressed("show_sword"):
		show_sword()
	if event.is_action_pressed("light"):
		if Global.can_light:
			lights_on(true)
	if event.is_action_pressed("interact"):
		if picked_object == null:
			pick_object()
		else:
			release_object()
	if event.is_action_pressed("BMM"):
		if picked_object != null:
			throw_object()
			release_object()
	if event.is_action_pressed("show_wand"):
		show_wand()
	
	# OPTIMISATION: Logique de tir déplacée dans _input au lieu de _physics_process
	if event.is_action_pressed("fire") and can_move:
		_handle_attack()

func set_can_move(value: bool):
	can_move = value
	
	# Si on désactive le mouvement, forcer l'animation idle immédiatement
	if not can_move:
		movement_speed = 0.0
		if animation_tree:
			animation_tree["parameters/iwr_blend/blend_amount"] = -1.0
		strafe_dir = Vector3.ZERO
		strafe = Vector3.ZERO
		
		velocity = Vector3.ZERO
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_INHERIT

# OPTIMISATION: Fonction séparée pour gérer les attaques
func _handle_attack() -> void:
	if not can_shoot:
		return
		
	if wand.visible and aiming:
		fire()
		$ShootAudioStreamPlayer.play()
		animation_tree["parameters/throw/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	elif sword_visible and is_on_floor() and has_found_whip:
		_handle_whip_attack()

func _handle_whip_attack() -> void:
	rope_shaded.show()
	animation_tree["parameters/slice/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	can_shoot = false
	can_move = false
	
	await get_tree().create_timer(0.3).timeout
	sword_hit.set_deferred("monitoring", true)
	check_whip_raycast()
	
	await get_tree().create_timer(0.2).timeout
	can_shoot = true
	sword_hit.set_deferred("monitoring", false)
	
	await get_tree().create_timer(0.3).timeout
	rope_shaded.hide()
	can_move = true

func _physics_process(delta):
	if not can_move or not Global.input_allowed():
		return
	
	# OPTIMISATION: Cache la rotation caméra une seule fois
	var h_rot = $camroot/h.global_transform.basis.get_euler().y
	
	# Handle behavior when grappling
	if grapple_controller.launched:
		_handle_grappling(delta, h_rot)
	else:
		_handle_normal_movement(delta, h_rot)
	
	# Appliquer move_and_slide() dans tous les cas
	move_and_slide()
	
	# Simule poids si sur seesaw
	if shapecast.is_colliding() and is_on_floor():
		var collider = shapecast.get_collider(0)
		if collider and collider.is_in_group("seesaw"):
			var seesaw: RigidBody3D = collider
			var hit_pos_world = shapecast.get_collision_point(0)
			var hit_pos_local = seesaw.to_local(hit_pos_world)
			
			# Lever arm le long de Z (axe seesaw)
			var lever_arm = hit_pos_local.z
			if abs(lever_arm) > 0.01:  # Évite micro-torque
				var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
				var torque_mag = player_mass * _gravity * abs(lever_arm)
				var torque = Vector3(sign(lever_arm) * torque_mag, 0, 0)
				seesaw.apply_torque(torque)
	
	
	# Post-movement logic (non grappling seulement)
	if not grapple_controller.launched:
		_handle_post_movement(delta)

# OPTIMISATION: Logique de grappling séparée
func _handle_grappling(delta: float, h_rot: float) -> void:
	model.rotation.y = lerp_angle(model.rotation.y, h_rot, delta * angular_acceleration)
	animation_tree["parameters/jump_transition/transition_request"] = "jumping"
	
	if not is_on_floor():
		vertical_velocity -= (gravity * 0.2) * delta
		vertical_velocity = max(vertical_velocity, -5.0)
	else:
		vertical_velocity = 0
	
	velocity.y += vertical_velocity * delta

# OPTIMISATION: Logique de mouvement normal séparée et simplifiée
func _handle_normal_movement(delta: float, h_rot: float) -> void:
	velocity = Vector3.ZERO
	
	# OPTIMISATION: Cache l'état d'aim une seule fois
	var is_aiming_input = Input.is_action_pressed("aim")
	current_aim_state = "aiming" if is_aiming_input else "not_aiming"
	animation_tree["parameters/aim_transition/transition_request"] = current_aim_state
	aiming = is_aiming_input
	
	# Handle input direction
	var has_movement_input = (Input.is_action_pressed("forward") or 
							   Input.is_action_pressed("backward") or 
							   Input.is_action_pressed("left") or 
							   Input.is_action_pressed("right"))
	
	if has_movement_input:
		_process_movement_input(delta, h_rot)
	else:
		_process_idle(delta, h_rot)
	
	# Apply horizontal velocity
	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)
	# IMPORTANT: Ajouter vertical_velocity, ne pas écraser !
	velocity = velocity + Vector3.UP * vertical_velocity
	
	# Glider
	_handle_glider()
	
	# Ventilator
	_handle_ventilator()
	
	# Rotation
	_handle_rotation(delta, h_rot)
	
	# Strafe animation
	strafe = lerp(strafe, strafe_dir, delta * acceleration)
	animation_tree["parameters/strafe/blend_position"] = Vector2(-strafe.x, strafe.z)
	
	# JUMPING - Inline pour garder l'ordre exact de l'original
	# Coyote Timer
	if not is_on_floor() and last_floor and not jumping:
		coyote_timer.start(coyote_time_duration)

	# Jump Buffering
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start(jump_buffer_duration)
	
	var can_coyote_jump = not coyote_timer.is_stopped()
	var has_buffered_jump = not jump_buffer_timer.is_stopped()

	# Reset jump count on floor (mais pas l'animation à chaque frame !)
	# Et ne pas reset si on est en train de sauter !
	if is_on_floor() and not jumping:
		jump_number = 0
		# Ne mettre l'animation à not_jumping QUE si on vient d'atterrir (pas à chaque frame)
		if not last_floor:
			animation_tree["parameters/jump_transition/transition_request"] = "not_jumping"

	# Execute jump
	var just_jumped = false  # Flag pour savoir si on vient de sauter cette frame
	if has_buffered_jump:
		# First jump (from ground or coyote time)
		if is_on_floor() or can_coyote_jump:
			if can_coyote_jump:
				coyote_timer.stop()
			jump_buffer_timer.stop()
			
			jump_number = 1
			jumping = true
			just_jumped = true
			vertical_velocity = jump_magnitude
			animation_tree["parameters/jump_transition/transition_request"] = "jumping"
			if anim_state_machine:
				anim_state_machine.travel("Jump_Start")
		# Double jump
		elif jump_number == 1 and can_double_jump:
			jump_buffer_timer.stop()
			
			jump_number = 0
			just_jumped = true
			vertical_velocity = jump_magnitude
			animation_tree["parameters/jump_transition/transition_request"] = "jumping"
			if anim_state_machine:
				anim_state_machine.travel("Jump_Start")

	# Landing (mais pas si on vient juste de sauter cette frame !)
	if is_on_floor() and not last_floor and not just_jumped:
		jumping = false
		animation_tree["parameters/jump_transition/transition_request"] = "not_jumping"
	
	# Falling
	if not is_on_floor() and not jumping:
		if anim_state_machine:
			anim_state_machine.travel("Jump_Idle")
		animation_tree["parameters/jump_transition/transition_request"] = "jumping"
	
	last_floor = is_on_floor()
	
	# Picked object
	_handle_picked_object()

# OPTIMISATION: Mouvement séparé
func _process_movement_input(delta: float, h_rot: float) -> void:
	direction = Vector3(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		0,
		Input.get_action_strength("forward") - Input.get_action_strength("backward")
	)
	
	strafe_dir = direction
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	# OPTIMISATION: Simplification de la logique de vitesse
	if sprinting and current_aim_state == "not_aiming":
		movement_speed = run_speed
		target_blend_amount = 1.0
	else:
		movement_speed = walk_speed
		target_blend_amount = 0.0
	
	# OPTIMISATION: Un seul appel lerp au lieu de deux
	animation_tree["parameters/iwr_blend/blend_amount"] = lerp(
		animation_tree.get("parameters/iwr_blend/blend_amount"), 
		target_blend_amount, 
		delta * acceleration
	)

# OPTIMISATION: Idle séparé
func _process_idle(delta: float, _h_rot: float) -> void:
	movement_speed = 0.0
	animation_tree["parameters/iwr_blend/blend_amount"] = lerp(
		animation_tree.get("parameters/iwr_blend/blend_amount"), 
		-1.0, 
		delta * acceleration
	)
	strafe_dir = Vector3.ZERO
	
	if current_aim_state == "aiming":
		direction = $camroot/h.global_transform.basis.z

# OPTIMISATION: Glider séparé
func _handle_glider() -> void:
	if Input.is_action_pressed("glide") and Global.can_glide and not is_on_floor() and velocity.y < 0:
		parapente.show()
		gravity = 5.0
	elif Input.is_action_just_released("glide"):
		parapente.hide()
		gravity = 28.0

# OPTIMISATION: Ventilator séparé
func _handle_ventilator() -> void:
	gravity = -15 if is_in_ventilator else 28

# OPTIMISATION: Gravité séparée
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0

# OPTIMISATION: Rotation séparée
func _handle_rotation(delta: float, h_rot: float) -> void:
	if current_aim_state == "not_aiming":
		model.rotation.y = lerp_angle(model.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)
	else:
		model.rotation.y = lerp_angle(model.rotation.y, h_rot, delta * angular_acceleration)

# OPTIMISATION: Jumping séparé et simplifié
# OPTIMISATION: Picked object séparé
func _handle_picked_object() -> void:
	if picked_object == null:
		return
	if picked_object.has_method("add_highlight"):
		picked_object.add_highlight()
	var velocity_to_hand = (hand.global_transform.origin - picked_object.global_transform.origin) * pull_power
	picked_object.set_linear_velocity(velocity_to_hand)

# OPTIMISATION: Post-movement séparé
func _handle_post_movement(delta: float) -> void:
	# Fall damage
	if old_vel < 0:
		var diff = velocity.y - old_vel
		if diff > fall_damage_thresold and is_on_floor():
			damage_received()
	old_vel = velocity.y
	
	# Rigidbody interactions
	push_factor = clamp(velocity.length(), 1.5, 10)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force * push_factor)
	
	# IMPORTANT: La gravité est appliquée APRÈS move_and_slide pour la PROCHAINE frame
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		# Ne remettre à 0 que si on n'est pas en train de sauter
		if not jumping:
			vertical_velocity = 0

# OPTIMISATION: Gestion de la mort via signal au lieu de vérifier à chaque frame
func _on_health_changed(_new_health) -> void:
	if Global.health <= 0:
		_handle_death()

func _handle_death() -> void:
	$CollisionShape3D.disabled = true
	animation_tree["parameters/die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	set_physics_process(false)
	
	await get_tree().create_timer(4.5).timeout
	
	CheckpointManager.respawn_player()
	$CollisionShape3D.disabled = false
	set_physics_process(true)
	Global.health = 100
	Global.emit_health_update()

func disable_controls() -> void:
	can_move = false
	
func enable_controls() -> void:
	can_move = true
	
########## Catapult eject force ###################
func launch_from_catapult(force: float):
	vertical_velocity = jump_magnitude * force
	
######### Whip particules trigger ##########################################
func whip_effect():
	%sparks.emitting = true
	%smoke.emitting = true

func check_whip_raycast() -> void:
	if not %WhipRayCast3D.is_colliding():
		return
		
	var target = %WhipRayCast3D.get_collider()
	if not target:
		return
		
	if target.is_in_group("Wall") or target.is_in_group("Enemy"):
		await get_tree().create_timer(0.4).timeout
		target.hit(2)
	
func check_sword_raycast():
	if sword_ray_cast_3d.is_colliding():
		if sword_ray_cast_3d.get_collider().is_in_group("Wall"):
			sword_ray_cast_3d.get_collider().hit(2)

func fire():
	can_shoot = false
	instance = bullet.instantiate()
	instance.position = muzzle.global_position
	instance.transform.basis = muzzle.global_transform.basis
	get_parent().add_child(instance)
	shoot_timer.start()

func _on_shoot_timer_timeout():
	can_shoot = true

func damage_received():
	hurt_overlay.modulate = Color.WHITE
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween()
	hurt_tween.tween_property(hurt_overlay, "modulate", Color.TRANSPARENT, 0.5)
	
	if Global.health > 0:
		animation_tree["parameters/hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		hurt_audio_stream_player.play()
		Global.health -= 10
		Global.emit_health_update()
	
func pick_object() -> void:
	var collider = interaction_raycast.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider

func release_object() -> void:
	if picked_object != null:
		if picked_object.has_method("remove_highlight"):
			picked_object.remove_highlight()
		picked_object = null
	
func throw_object() -> void:
	var knockback = picked_object.position - position
	picked_object.apply_central_impulse(knockback * throwing_force)
	release_object()
	throw_audio_stream_player.play()
	
func pausing(on):
	set_physics_process(!on)

func show_wand() -> void:
	animation_tree.set("parameters/pickup/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	wand.visible = !wand.visible
	$IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D/sword_rare_gltf.hide()

func show_sword() -> void:
	$IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D/sword_rare_gltf.show()
	animation_tree.set("parameters/slice/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	wand.hide()

func _on_inventory_visibility_changed() -> void:
	if $Inventory.visible :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

func hide_tuto():
	tuto_visible = false
	var tween = get_tree().create_tween()
	tween.tween_property(%tuto, "position", Vector2(-212,219), 0.6)

func _on_note_pickup_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

func _on_sword_hit_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		body.hit(25)

func open_door():
	animation_tree["parameters/OpenOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func lights_on(_value : bool) -> void:
	%SpotLight3D.visible = !%SpotLight3D.visible
	Global.light_on.emit(%SpotLight3D.visible)

func lanternoff():
	%SpotLight3D.hide()

func play_foot_step() -> void:
	$AudioStreamPlayer.pitch_scale = randf_range(0.8, 1.2)
	$AudioStreamPlayer.play()

func shake() -> void:
	if camroot:
		camroot.add_shake(0.2)
