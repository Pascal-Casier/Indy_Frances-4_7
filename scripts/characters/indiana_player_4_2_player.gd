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

func _ready():
	Global.on_pause_mode.connect(pausing)
	Global.has_sword.connect(show_sword)
	Global.lantern_off.connect(lanternoff)
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


func _input(event):
	if Global.mode == Global.GameMode.READING:
		return
	if Global.input_allowed():
		if sprint_toggle:
			if event.is_action_pressed("sprint"):
				sprinting = false if sprinting else true
		else:
			sprinting = Input.is_action_pressed("sprint")
		
		if Input.is_action_pressed("toggle_sprint"):
			sprint_toggle = false if sprint_toggle else true
			
		if event.is_action_pressed("show_sword"):
			show_sword()
		if event.is_action_pressed("light"):
			if Global.can_light:
				lights_on(true)
		if event.is_action_pressed("interact"):
			if picked_object == null:
				pick_object()
			elif picked_object != null:
				release_object()
		if event.is_action_pressed("BMM"):
			if picked_object !=null:
				throw_object()
				release_object()
		if event.is_action_pressed("show_wand"):
			show_wand()
		
					
		#if event.is_action_pressed("tab"):
			#if !tuto_visible:
				#show_tuto()
			#else:
				#hide_tuto()
	############### Grapin ###############
		if event.is_action_pressed("grapple"):
			# La logique est maintenant dans GrappleController
			pass
######################################

func set_can_move(value: bool):
	can_move = value
	
	# Si on désactive le mouvement, forcer l'animation idle immédiatement
	if not can_move:
		movement_speed = 0.0
		if animation_tree:  # Vérifier que l'animation_tree existe
			animation_tree["parameters/iwr_blend/blend_amount"] = -1.0
		strafe_dir = Vector3.ZERO
		strafe = Vector3.ZERO
		
		# Optionnel : arrêter aussi la vélocité
		velocity = Vector3.ZERO
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_DISABLED
	if can_move:
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_INHERIT
				
func _physics_process(delta):
	if not can_move or not Global.input_allowed():
		return
		
	# On récupère la rotation horizontale de la caméra pour l'orientation
	var h_rot = $camroot/h.global_transform.basis.get_euler().y
	
	# Handle behavior when grappling
	if grapple_controller.launched:
		$IndianaJones_Model_4_2.rotation.y = lerp_angle($IndianaJones_Model_4_2.rotation.y, h_rot, delta * angular_acceleration)
		animation_tree["parameters/jump_transition/transition_request"] = "jumping"
		
		# Ne pas altérer la vélocité calculée par le contrôleur de grappin
		# On laisse simplement la gravité s'appliquer légèrement
		if !is_on_floor():
			# Appliquer une gravité très légère pour éviter l'effet de flottement tout en permettant au grappin de tirer
			vertical_velocity -= (gravity * 0.2) * delta
			
			# On s'assure que la gravité ne contrecarre pas trop l'effet du grappin
			vertical_velocity = max(vertical_velocity, -5.0)
		else:
			vertical_velocity = 0
		
		# On applique uniquement la composante verticale calculée ci-dessus
		# IMPORTANT: Ne pas modifier les composantes X et Z qui sont calculées par le grappin
		velocity.y += vertical_velocity * delta
	
	# Reset velocity only if NOT grappling
	else:
	
		velocity = Vector3.ZERO
		if Input.is_action_pressed("aim"):
			animation_tree["parameters/aim_transition/transition_request"] = "aiming"
			aiming = true
		else:
			animation_tree["parameters/aim_transition/transition_request"] = "not_aiming"
			aiming = false
			
		
		# h_rot est déjà défini plus haut dans la fonction
		
		if Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
							0,
							Input.get_action_strength("forward") - Input.get_action_strength("backward"))
			
			strafe_dir = direction
			direction = direction.rotated(Vector3.UP, h_rot).normalized()
			
			
			if sprinting && animation_tree.get("parameters/aim_transition/current_state") == "not_aiming":
				movement_speed = run_speed
				animation_tree["parameters/iwr_blend/blend_amount"] = lerp(animation_tree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration)
			else:
				movement_speed = walk_speed
				animation_tree["parameters/iwr_blend/blend_amount"] = lerp(animation_tree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration)
		else:
			movement_speed = 0.0
			animation_tree["parameters/iwr_blend/blend_amount"] = lerp(animation_tree.get("parameters/iwr_blend/blend_amount"), -1.0 , delta * acceleration)
			strafe_dir = Vector3.ZERO
			
			if animation_tree.get("parameters/aim_transition/current_state") == "aiming":
				direction = $camroot/h.global_transform.basis.z

		
		velocity = lerp(velocity, direction * movement_speed, delta * acceleration)
		velocity = velocity + Vector3.UP * vertical_velocity 
		
		####### Glider #######
		if Input.is_action_pressed("glide") and Global.can_glide and !is_on_floor() and velocity.y < 0:
			parapente.show()
			gravity = 5.0
		if Input.is_action_just_released("glide"):
			parapente.hide()
			gravity = 28.0
		
		###########3 Ventilo Effect###################
		if is_in_ventilator :
			gravity = -15
		else:
			gravity = 28
		##############################################
	
	# Appliquer move_and_slide() que le grappin soit actif ou non
	move_and_slide()
	
	# La suite n'est exécutée que si on n'est PAS en train de grappler
	if !grapple_controller.launched:
		####### Handle fall damage###############
		if old_vel < 0:
			var diff = velocity.y - old_vel
			if diff > fall_damage_thresold and is_on_floor():
				damage_received()
		old_vel = velocity.y
		
		##handle interaction with rigidbodies#################
		push_factor = velocity.length()
		push_factor = clamp(push_factor, 1.5, 10)
		
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force * push_factor)
		###########################
		
		if !is_on_floor():
			vertical_velocity -= gravity * delta
		else:
			vertical_velocity = 0
		
		if animation_tree.get("parameters/aim_transition/current_state") == "not_aiming":
			$IndianaJones_Model_4_2.rotation.y = lerp_angle($IndianaJones_Model_4_2.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)
		else:
			$IndianaJones_Model_4_2.rotation.y = lerp_angle($IndianaJones_Model_4_2.rotation.y, h_rot, delta * angular_acceleration)
			
		strafe = lerp(strafe, strafe_dir, delta * acceleration)
		
		animation_tree["parameters/strafe/blend_position"] = Vector2(-strafe.x, strafe.z)
		velocity = direction 
		
		
		
		########### SHOOTING / SWORD SWAYING###############		
		if Input.is_action_just_pressed("fire"):
			set_physics_process(false)
			if can_shoot and wand.visible and aiming:
				fire()
				$ShootAudioStreamPlayer.play()
				animation_tree["parameters/throw/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			elif can_shoot and sword_visible and is_on_floor() and has_found_whip:
				rope_shaded.show()
				animation_tree["parameters/slice/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				can_shoot = false
				await get_tree().create_timer(0.3).timeout
				sword_hit.set_deferred("monitoring", true)
				#check_sword_raycast()
				check_whip_raycast()
				await get_tree().create_timer(0.2).timeout
				can_shoot = true
				sword_hit.set_deferred("monitoring", false)
				await get_tree().create_timer(0.3).timeout
				rope_shaded.hide()
			
			set_physics_process(true)
				
				
		#JUMPING
		# Coyote Timer: start if we just walked off a ledge
		if not is_on_floor() and last_floor and not jumping:
			coyote_timer.start(coyote_time_duration)

		# Jump Buffering: start the timer whenever jump is pressed
		if Input.is_action_just_pressed("jump"):
			jump_buffer_timer.start(jump_buffer_duration)
		
		var can_coyote_jump = not coyote_timer.is_stopped()
		var has_buffered_jump = not jump_buffer_timer.is_stopped()

		# Reset jump count on floor
		if is_on_floor():
			jump_number = 0
			animation_tree["parameters/jump_transition/transition_request"] = "not_jumping"

		# Check if we should execute a jump (regular, double, coyote, or buffered)
		if has_buffered_jump:
			# First jump (from ground or coyote time)
			if is_on_floor() or can_coyote_jump:
				if can_coyote_jump:
					coyote_timer.stop()
				jump_buffer_timer.stop() # Consume the buffer
				
				jump_number = 1
				jumping = true
				vertical_velocity = jump_magnitude
				animation_tree["parameters/jump_transition/transition_request"] = "jumping"
				animation_tree["parameters/JumpStateMachine/playback"].travel("Jump_Start")
			# Double jump
			elif jump_number == 1 and can_double_jump:
				jump_buffer_timer.stop() # Consume the buffer
				
				jump_number = 0 # Use original logic: 0 means no more air jumps
				vertical_velocity = jump_magnitude
				animation_tree["parameters/jump_transition/transition_request"] = "jumping"
				animation_tree["parameters/JumpStateMachine/playback"].travel("Jump_Start")

		if is_on_floor() and not last_floor:
			jumping = false
			animation_tree["parameters/jump_transition/transition_request"] = "not_jumping"
		
		if not is_on_floor() and not jumping:
			animation_tree["parameters/JumpStateMachine/playback"].travel("Jump_Idle")
			animation_tree["parameters/jump_transition/transition_request"] = "jumping"
		
		last_floor = is_on_floor()
		
		####### HANDLING PICKED OBJECT ################
		
		if picked_object != null:
			picked_object.add_highlight()
			var a = picked_object.global_transform.origin
			var b = hand.global_transform.origin
			picked_object.set_linear_velocity((b-a) * pull_power)
	#################################################
	
	########### Dying ##################
	if Global.health <= 0:
		$CollisionShape3D.disabled = true
		animation_tree["parameters/die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		set_physics_process(false)
		await get_tree().create_timer(4.5).timeout
		#global_transform.origin = Vector3.ZERO
		CheckpointManager.respawn_player()
		$CollisionShape3D.disabled = false
		set_physics_process(true)
		Global.health = 100
		Global.emit_health_update()
	######################################	

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
	if %WhipRayCast3D.is_colliding():
		var target = %WhipRayCast3D.get_collider()
		if target:
			if target.is_in_group("Wall"):
				await get_tree().create_timer(0.4).timeout
				target.hit(2)
			elif target.is_in_group("Enemy"):
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

#func show_tuto():
	#tuto_visible = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(%tuto, "position", Vector2(0,219), 0.6)

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
