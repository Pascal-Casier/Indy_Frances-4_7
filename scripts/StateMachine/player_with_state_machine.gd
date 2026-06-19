extends CharacterBody3D

# ---------------------------------------------------------------------------
# Toutes les references aux nœuds sont résolues dans _ready() avec get_node_or_null.
# Si un nœud n'existe pas (scène de test), la variable reste null.
# Le code vérifie toujours "if <var>:" avant d'utiliser ces references.
# ---------------------------------------------------------------------------
var interaction_raycast
var hand
var throw_audio_stream_player
var hurt_audio_stream_player
var wand
var hurt_overlay
var parapente
var animation_tree
var sword_hit
var sword_ray_cast_3d
var rope_shaded
var camroot
var state_machine
var grapple_controller

# Utilisé par les etats pour la rotation du modèle
var model: Node3D
# Utilisé par les etats pour obtenir la rotation de la caméra (nœud "h")
var cam_h: Node3D

var is_releasing_grapple := false

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

# Vitesse de mouvement en l'air (capturée au moment du saut)
var air_movement_speed := 0.0

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

var shoot_timer
var can_shoot := true
var muzzle
var bullet = preload("res://scenes/mechanics/bullet_lighning.tscn")
var instance
var is_attacking := false
var tuto_visible := false

func _ready():
	Global.health = 100
	Global.emit_health_update()
	# ---------------------------------------------------------------
	# Résolution sécurisée de tous les nœuds.
	# get_node_or_null retourne null si le nœud n'existe pas : pas d'erreur.
	# ---------------------------------------------------------------
	interaction_raycast = get_node_or_null("IndianaJones_Model_4_2/interactionRaycast")
	hand                = get_node_or_null("IndianaJones_Model_4_2/hand")
	throw_audio_stream_player = get_node_or_null("ThrowAudioStreamPlayer")
	hurt_audio_stream_player  = get_node_or_null("HurtAudioStreamPlayer")
	wand                = get_node_or_null("IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D2/1H_Wand")
	hurt_overlay        = get_node_or_null("Hurt_overlay")
	parapente           = get_node_or_null("IndianaJones_Model_4_2/Parapente")
	animation_tree      = get_node_or_null("IndianaJones_Model_4_2/AnimationTree")
	sword_hit           = get_node_or_null("IndianaJones_Model_4_2/indy/GeneralSkeleton/sword_hit")
	sword_ray_cast_3d   = get_node_or_null("IndianaJones_Model_4_2/indy/GeneralSkeleton/SwordRayCast3D")
	rope_shaded         = get_node_or_null("%RopeShaded")
	camroot             = get_node_or_null("camroot")
	state_machine       = get_node_or_null("StateMachine")
	grapple_controller  = get_node_or_null("GrappingController")
	shoot_timer         = get_node_or_null("Shoot_Timer")
	muzzle              = get_node_or_null("%muzzle")
	
	# Raccourcis utilisés par les etats
	model = get_node_or_null("IndianaJones_Model_4_2")
	cam_h = get_node_or_null("camroot/h")
	
	# ---------------------------------------------------------------
	# Connexions de signaux (seulement si les cibles existent)
	# ---------------------------------------------------------------
	if Global.has_signal("on_pause_mode"):
		Global.on_pause_mode.connect(pausing)
	if Global.has_signal("has_sword"):
		Global.has_sword.connect(show_sword)
	if Global.has_signal("lantern_off"):
		Global.lantern_off.connect(lanternoff)
	
	if camroot and camroot.has_node("h/v/SpringArm3D"):
		camroot.get_node("h/v/SpringArm3D").spring_length = arm3D_lenght
	
	# Timers créés en code
	coyote_timer = Timer.new()
	coyote_timer.name = "CoyoteTimer"
	coyote_timer.one_shot = true
	add_child(coyote_timer)

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

func set_can_move(value: bool):
	can_move = value
	
	if not can_move:
		movement_speed = 0.0
		if animation_tree:
			animation_tree["parameters/iwr_blend/blend_amount"] = -1.0
		strafe_dir = Vector3.ZERO
		strafe = Vector3.ZERO
		velocity = Vector3.ZERO
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_DISABLED
		if state_machine:
			state_machine.set_physics_process(false)
			state_machine.set_process(false)
	if can_move:
		if camroot:
			camroot.process_mode = Node.PROCESS_MODE_INHERIT
		if state_machine:
			state_machine.set_physics_process(true)
			state_machine.set_process(true)

func _physics_process(delta):
	if not can_move or not Global.input_allowed():
		return
	
	# Gérer le coyote time
	if not is_on_floor() and last_floor and not jumping:
		coyote_timer.start(coyote_time_duration)
	
	last_floor = is_on_floor()
	
	# Appliquer la gravité si on n'est pas en train de grappler
	# NOTE: on ne touche pas vertical_velocity si jumping == true ce frame,
	# parce que state_jump.enter() vient de le poser à jump_magnitude
	var is_grappling = grapple_controller and grapple_controller.launched
	if not is_grappling:
		if jumping:
			pass  # vertical_velocity déjà mis à jour par state_jump.enter()
		elif not is_on_floor():
			vertical_velocity -= gravity * delta
		else:
			vertical_velocity = 0
		
		# Appliquer la vélocité verticale
		velocity.y = vertical_velocity
		
		# Resetter le flag jumping après avoir appliqué la vélocité.
		# La gravité reprendra normalement le frame suivant.
		if jumping:
			jumping = false
	
	# Gérer les objets ramassés
	if picked_object != null and hand != null:
		picked_object.add_highlight()
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)
	
	# Appliquer le mouvement (la state machine modifie velocity)
	move_and_slide()
	
	# Gérer les dégâts de chute
	if not is_grappling:
		if old_vel < 0:
			var diff = velocity.y - old_vel
			if diff > fall_damage_thresold and is_on_floor():
				damage_received()
		old_vel = velocity.y
		
		# Interaction avec les rigidbodies
		push_factor = velocity.length()
		push_factor = clamp(push_factor, 1.5, 10)
		
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody3D:
				c.get_collider().apply_central_impulse(-c.get_normal() * push_force * push_factor)

########## Catapult eject force ###################
func launch_from_catapult(force: float):
	vertical_velocity = jump_magnitude * force

######### Whip particules trigger ##########################################
func whip_effect():
	var sparks = get_node_or_null("%sparks")
	var smoke = get_node_or_null("%smoke")
	if sparks: sparks.emitting = true
	if smoke: smoke.emitting = true

func check_whip_raycast() -> void:
	var whip_raycast = get_node_or_null("%WhipRayCast3D")
	if not whip_raycast: return
	if whip_raycast.is_colliding():
		var target = whip_raycast.get_collider()
		if target:
			if target.is_in_group("Wall"):
				await get_tree().create_timer(0.4).timeout
				target.hit(2)
			elif target.is_in_group("Enemy"):
				await get_tree().create_timer(0.4).timeout
				target.hit(2)

func check_sword_raycast():
	if not sword_ray_cast_3d: return
	if sword_ray_cast_3d.is_colliding():
		if sword_ray_cast_3d.get_collider().is_in_group("Wall"):
			sword_ray_cast_3d.get_collider().hit(2)

func fire():
	if not muzzle or not shoot_timer: return
	can_shoot = false
	instance = bullet.instantiate()
	instance.position = muzzle.global_position
	instance.transform.basis = muzzle.global_transform.basis
	get_parent().add_child(instance)
	shoot_timer.start()

func _on_shoot_timer_timeout():
	can_shoot = true

func damage_received():
	if hurt_overlay:
		hurt_overlay.modulate = Color.WHITE
		if hurt_tween:
			hurt_tween.kill()
		hurt_tween = create_tween()
		hurt_tween.tween_property(hurt_overlay, "modulate", Color.TRANSPARENT, 0.5)
	
	if Global.health > 0:
		if animation_tree:
			animation_tree["parameters/hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if hurt_audio_stream_player:
			hurt_audio_stream_player.play()
		Global.health -= 10
		Global.emit_health_update()

func pick_object() -> void:
	if not interaction_raycast: return
	var collider = interaction_raycast.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider

func release_object() -> void:
	if picked_object != null:
		picked_object.remove_highlight()
		picked_object = null

func throw_object() -> void:
	if not picked_object: return
	var knockback = picked_object.position - position
	picked_object.apply_central_impulse(knockback * throwing_force)
	release_object()
	if throw_audio_stream_player:
		throw_audio_stream_player.play()

func pausing(on):
	set_physics_process(!on)

func show_wand() -> void:
	if not animation_tree or not wand: return
	animation_tree.set("parameters/pickup/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	wand.visible = !wand.visible
	var sword_gltf = get_node_or_null("IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D/sword_rare_gltf")
	if sword_gltf: sword_gltf.hide()

func show_sword() -> void:
	var sword_gltf = get_node_or_null("IndianaJones_Model_4_2/indy/GeneralSkeleton/BoneAttachment3D/sword_rare_gltf")
	if sword_gltf: sword_gltf.show()
	if animation_tree:
		animation_tree.set("parameters/slice/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	if wand: wand.hide()

func _on_inventory_visibility_changed() -> void:
	var inventory = get_node_or_null("Inventory")
	if not inventory: return
	if inventory.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

#func hide_tuto():
	#var tuto = get_node_or_null("%tuto")
	#if not tuto: return
	#tuto_visible = false
	#var tween = get_tree().create_tween()
	#tween.tween_property(tuto, "position", Vector2(-212,219), 0.6)

#func _on_note_pickup_body_exited(_body: Node3D) -> void:
	#pass

func _on_sword_hit_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		body.hit(25)

func open_door():
	if animation_tree:
		animation_tree["parameters/OpenOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func lights_on(_value : bool) -> void:
	var spot = get_node_or_null("%SpotLight3D")
	if not spot: return
	spot.visible = !spot.visible
	Global.light_on.emit(spot.visible)

func lanternoff():
	var spot = get_node_or_null("%SpotLight3D")
	if spot: spot.hide()

func play_foot_step() -> void:
	var audio = get_node_or_null("AudioStreamPlayer")
	if not audio: return
	audio.pitch_scale = randf_range(0.8, 1.2)
	audio.play()

func shake() -> void:
	if camroot:
		camroot.add_shake(0.2)

func disable_controls() -> void:
	can_move = false

func enable_controls() -> void:
	can_move = true
