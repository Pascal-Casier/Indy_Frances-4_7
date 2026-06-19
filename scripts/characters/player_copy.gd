extends CharacterBody3D

@onready var interaction_raycast = $Mage/interactionRaycast
@onready var hand = $Mage/hand
@onready var throw_audio_stream_player = $ThrowAudioStreamPlayer
@onready var hurt_audio_stream_player = $HurtAudioStreamPlayer
@onready var spellbook = $Mage/Rig/Skeleton3D/Spellbook/Spellbook
@onready var wand = $"Mage/Rig/Skeleton3D/1H_Wand/1H_Wand"
@onready var staff = $"Mage/Rig/Skeleton3D/2H_Staff/2H_Staff"
@onready var cape = $Mage/Rig/Skeleton3D/Mage_Cape/Mage_Cape
@onready var hat = $Mage/Rig/Skeleton3D/Mage_Hat/Mage_Hat
@onready var hurt_overlay: TextureRect = $Hurt_overlay
@onready var sword_ray_cast_3d: RayCast3D = %SwordRayCast3D

@export var throwing_force : int = 200

var movement_speed := 0.0
var run_speed := 85
var walk_speed := 60
var acceleration := 6
var jump_magnitude := 12.0
var vertical_velocity := 0.0
var gravity := 28.0
var angular_acceleration := 7

var direction := Vector3.FORWARD
var strafe_dir := Vector3.ZERO
var strafe := Vector3.ZERO

var jumping := false
var last_floor := true
var jump_available : bool = true
var jump_number := 0

var sprint_toggle := true
var sprinting := false

var aiming : bool = false

var sword_visible : bool = true

######## fall Damage mechanic ################
var old_vel : float = 0.0
@export var fall_damage_thresold = 20
var hurt_tween : Tween

var push_force := 25.0
var push_factor := 0.0

var picked_object
var pull_power := 5

@onready var shoot_timer = $Shoot_Timer
var can_shoot := true
@onready var muzzle = %muzzle
var bullet = load("res://scenes/mechanics/bullet_lighning.tscn")
var instance

var tuto_visible := false

func _ready():
	Global.on_pause_mode.connect(pausing)
	Global.has_sword.connect(show_sword)

func _input(event):
	if sprint_toggle:
		if event.is_action_pressed("sprint"):
			sprinting = false if sprinting else true
	else:
		sprinting = Input.is_action_pressed("sprint")
	
	if Input.is_action_just_pressed("toggle_sprint"):
		sprint_toggle = false if sprint_toggle else true
		
	if event.is_action_pressed("show_sword"):
		show_sword()
		
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
	if event.is_action_pressed("inventory"):
		pass
		#%Inventaire.visible = !%Inventaire.visible
		#if %Inventaire.visible == false:
			#show()
			#get_tree().paused = true
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#elif %Inventaire.visible:
			#hide()
			#get_tree().paused = false
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		#if %Notebook.visible == false:
			#%Notebook.show()
			#get_tree().paused = true
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#else:
			#%Notebook.hide()
			#get_tree().paused = true
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if event.is_action_pressed("tab"):
		if !tuto_visible:
			show_tuto()
		else:
			hide_tuto()
				
func _physics_process(delta):
	velocity = Vector3.ZERO
	if Input.is_action_pressed("aim"):
		$AnimationTree["parameters/aim_transition/transition_request"] = "aiming"
		aiming = true
	else:
		$AnimationTree["parameters/aim_transition/transition_request"] = "not_aiming"
		aiming = false
		
	
	var h_rot = $camroot/h.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward")||Input.is_action_pressed("backward")||Input.is_action_pressed("left")||Input.is_action_pressed("right"):
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
						0,
						Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		
		strafe_dir = direction
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		
		
		if sprinting && $AnimationTree.get("parameters/aim_transition/current_state") == "not_aiming":
			movement_speed = run_speed
			$AnimationTree["parameters/iwr_blend/blend_amount"] = lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1.0, delta * acceleration)
		else:
			movement_speed = walk_speed
			$AnimationTree["parameters/iwr_blend/blend_amount"] = lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0.0, delta * acceleration)
	else:
		movement_speed = 0
		$AnimationTree["parameters/iwr_blend/blend_amount"] = lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), -1.0, delta * acceleration)
		strafe_dir = Vector3.ZERO
		
		if $AnimationTree.get("parameters/aim_transition/current_state") == "aiming":
			direction = $camroot/h.global_transform.basis.z

	
	velocity = lerp(velocity, direction * movement_speed, delta * acceleration)
	velocity = velocity + Vector3.UP * vertical_velocity
	move_and_slide()
	
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
	
	if $AnimationTree.get("parameters/aim_transition/current_state") == "not_aiming":
		$Mage.rotation.y = lerp_angle($Mage.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)
	else:
		$Mage.rotation.y = lerp_angle($Mage.rotation.y, h_rot, delta * angular_acceleration)
		
	strafe = lerp(strafe, strafe_dir, delta * acceleration)
	
	$AnimationTree["parameters/strafe/blend_position"] = Vector2(-strafe.x, strafe.z)
	velocity = direction
	
	########### SHOOTING / SWORD SWAYING###############		
	if Input.is_action_just_pressed("fire"):
		if can_shoot and wand.visible and aiming:
			fire()
			$ShootAudioStreamPlayer.play()
			$AnimationTree["parameters/throw/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		elif can_shoot and sword_visible and is_on_floor():
			$AnimationTree["parameters/slice/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			can_shoot = false
			await get_tree().create_timer(0.5).timeout
			%sword_hit.set_deferred("monitoring", true)
			check_sword_raycast()
			await get_tree().create_timer(0.8).timeout
			can_shoot = true
			%sword_hit.set_deferred("monitoring", false)
			
			
			
	#JUMPING
	if is_on_floor():
		jump_number = 0
		$AnimationTree["parameters/jump_transition/transition_request"] = "not_jumping"
		if Input.is_action_just_pressed("jump"):
			jump_number = 1
			jumping = true
			vertical_velocity = jump_magnitude
			$AnimationTree["parameters/jump_transition/transition_request"] = "jumping"
			$AnimationTree["parameters/JumpStateMachine/playback"].travel("Jump_Start")
	if is_on_floor() and not last_floor:
		jumping = false
		$AnimationTree["parameters/jump_transition/transition_request"] = "not_jumping"
	if not is_on_floor() and not jumping:
		$AnimationTree["parameters/JumpStateMachine/playback"].travel("Jump_Idle")
		$AnimationTree["parameters/jump_transition/transition_request"] = "jumping"
	last_floor = is_on_floor()
	if not is_on_floor():
		if Input.is_action_just_pressed("jump") and jump_number == 1:
			jump_number = 0
			vertical_velocity = jump_magnitude
			$AnimationTree["parameters/jump_transition/transition_request"] = "jumping"
			$AnimationTree["parameters/JumpStateMachine/playback"].travel("Jump_Start")
			
		
	
	####### HANDLING PICKED OBJECT ################
	
	if picked_object != null:
		picked_object.add_highlight()
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a) * pull_power)
	#################################################
	
	########### Dying##################
	if Global.health <= 0:
		$CollisionShape3D.disabled = true
		$AnimationTree["parameters/die/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		set_physics_process(false)
		await get_tree().create_timer(4.5).timeout
		global_transform.origin = Vector3.ZERO
		$CollisionShape3D.disabled = false
		set_physics_process(true)
		Global.health = 100
		Global.emit_health_update()
	######################################	

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
		$AnimationTree["parameters/hit/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
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
	$AnimationTree.set("parameters/pickup/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	wand.visible = !wand.visible
	%sword_rare.hide()

func show_sword() -> void:
	%sword_rare.show()
	$AnimationTree.set("parameters/slice/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	wand.hide()

func show_cape() -> void:
	cape.show()
	
func show_hat() -> void:
	hat.visible = !hat.visible


func _on_inventory_visibility_changed() -> void:
	if $Inventory.visible :
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false

func show_tuto():
	tuto_visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(%tuto, "position", Vector2(0,219), 0.6)

func hide_tuto():
	tuto_visible = false
	var tween = get_tree().create_tween()
	tween.tween_property(%tuto, "position", Vector2(-212,219), 0.6)


func _on_note_pickup_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.


func _on_sword_hit_body_entered(body: Node3D) -> void:
	if body.has_method("hit"):
		body.hit(25)
	#if body.has_method("knockback"):
		#body.knockback(global_transform.origin)
		
#func knockback(dir):
	#velocity +- dir * 20.0
