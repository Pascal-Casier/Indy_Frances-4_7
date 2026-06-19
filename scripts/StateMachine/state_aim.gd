extends PlayerState

func enter() -> void:
	player.aiming = true
	anim_set("parameters/aim_transition/transition_request", "aiming")
	anim_set("parameters/iwr_blend/blend_amount", -1.0)
	anim_set("parameters/strafe/blend_position", Vector2.ZERO)


func physics_update(delta: float) -> String:
	# --------------------
	# TRANSITIONS D'ÉTAT
	# --------------------
	if Global.health <= 0:
		return "Death"

	if not Input.is_action_pressed("aim"):
		return "Idle"

	if player.grapple_controller and player.grapple_controller.launched:
		return "Grapple"

	if not player.is_on_floor():
		player.air_movement_speed = player.movement_speed
		return "Fall"

	if Input.is_action_just_pressed("fire") and player.can_shoot:
		return "Attack"

	if not player.cam_h or not player.model:
		return ""

	# --------------------
	# INPUT
	# --------------------
	var input_dir := Vector3(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		0.0,
		Input.get_action_strength("forward") - Input.get_action_strength("backward")
	)

	var has_input := input_dir.length_squared() > 0.001
	var h_rot: float = player.cam_h.global_transform.basis.get_euler().y

	# --------------------
	# ROTATION (toujours)
	# --------------------
	player.model.rotation.y = lerp_angle(
		player.model.rotation.y,
		h_rot,
		delta * player.angular_acceleration
	)

	# --------------------
	# MOUVEMENT & ANIMATION
	# --------------------
	if has_input:
		_handle_aim_movement(input_dir, h_rot, delta)
	else:
		_handle_aim_idle(delta)

	return ""


func _handle_aim_movement(input_dir: Vector3, h_rot: float, delta: float) -> void:
	# Direction monde
	player.strafe_dir = input_dir
	var direction := input_dir.rotated(Vector3.UP, h_rot).normalized()
	player.direction = direction

	# Mouvement
	player.movement_speed = player.walk_speed
	var target_velocity: Vector3 = direction * player.movement_speed
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, delta * player.acceleration)
	player.velocity.z = lerp(player.velocity.z, target_velocity.z, delta * player.acceleration)

	# Animation walk / strafe
	anim_set("parameters/iwr_blend/blend_amount", 0.0)

	player.strafe = player.strafe.lerp(player.strafe_dir, delta * player.acceleration)
	anim_set(
		"parameters/strafe/blend_position",
		Vector2(-player.strafe.x, player.strafe.z)
	)


func _handle_aim_idle(delta: float) -> void:
	player.movement_speed = 0.0

	var stop_force: float = delta * player.acceleration * 3.0
	player.velocity.x = lerp(player.velocity.x, 0.0, stop_force)
	player.velocity.z = lerp(player.velocity.z, 0.0, stop_force)

	if abs(player.velocity.x) < 0.05:
		player.velocity.x = 0.0
	if abs(player.velocity.z) < 0.05:
		player.velocity.z = 0.0

	player.direction = player.cam_h.global_transform.basis.z

	anim_set("parameters/iwr_blend/blend_amount", -1.0)
	player.strafe = Vector3.ZERO
	player.strafe_dir = Vector3.ZERO
	anim_set("parameters/strafe/blend_position", Vector2.ZERO)


func exit() -> void:
	player.aiming = false
	anim_set("parameters/aim_transition/transition_request", "not_aiming")


func handle_input(event: InputEvent) -> String:
	if event.is_action_pressed("jump"):
		return "Jump"
	return ""













#extends PlayerState
#
#func enter() -> void:
	#print("Entrée dans Aim")
	#player.aiming = true
	#anim_set("parameters/aim_transition/transition_request", "aiming")
	#anim_set("parameters/strafe/blend_position", Vector2.ZERO)
#
#func physics_update(delta: float) -> String:
	## Vérifier si le joueur est en vie
	#if Global.health <= 0:
		#return "Death"
	#
	## Sortir de la visée
	#if not Input.is_action_pressed("aim"):
		#return "Idle"
	#
	## Transition vers Grapple
	#if (player.grapple_controller and player.grapple_controller.launched):
		#return "Grapple"
	#
	## Transition vers Fall si en l'air
	#if not player.is_on_floor():
		#player.air_movement_speed = player.movement_speed
		#return "Fall"
	#
	## Transition vers Attack
	#if Input.is_action_just_pressed("fire") and player.can_shoot:
		#return "Attack"
	#
	## Logique de mouvement en visée
	#if not player.cam_h: return ""
	#if not player.model: return ""
	#var h_rot = player.cam_h.global_transform.basis.get_euler().y
	#
	#if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
	   #Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		#
		#var direction = Vector3(
			#Input.get_action_strength("left") - Input.get_action_strength("right"),
			#0,
			#Input.get_action_strength("forward") - Input.get_action_strength("backward")
		#)
		#
		#player.strafe_dir = direction
		#direction = direction.rotated(Vector3.UP, h_rot).normalized()
		#player.direction = direction
		#
		#
		#player.movement_speed = player.walk_speed
		#anim_set("parameters/iwr_blend/blend_amount", lerp(
			#(animation_tree.get("parameters/iwr_blend/blend_amount") if animation_tree else null), 
			#0.0, 
			#delta * player.acceleration
		#))
		#
		## Appliquer la vélocité HORIZONTALE
		#var target_velocity = direction * player.movement_speed
		#player.velocity.x = lerp(player.velocity.x, target_velocity.x, delta * player.acceleration)
		#player.velocity.z = lerp(player.velocity.z, target_velocity.z, delta * player.acceleration)
		#
		## Rotation du modèle vers la caméra
		#player.model.rotation.y = lerp_angle(
			#player.model.rotation.y,
			#h_rot,
			#delta * player.angular_acceleration
		#)
		#
		## Strafe animation
		#var strafe = lerp(player.strafe, player.strafe_dir, delta * player.acceleration)
		#player.strafe = strafe
		#anim_set("parameters/strafe/blend_position", Vector2(-strafe.x, strafe.z))
	#else:
		## Pas de mouvement, mais on vise toujours
		#player.movement_speed = 0.0
		#player.velocity.x = 0.0
		#player.velocity.z = 0.0
		#anim_set("parameters/iwr_blend/blend_amount", lerp(
			#(animation_tree.get("parameters/iwr_blend/blend_amount") if animation_tree else null), 
			#-1.0, 
			#delta * player.acceleration
		#))
		#player.strafe_dir = Vector3.ZERO
		#
		## Direction = là où regarde la caméra (ligne 225 ancien code)
		#player.direction = player.cam_h.global_transform.basis.z
		#
		## Rotation vers la caméra même sans mouvement
		#player.model.rotation.y = lerp_angle(
			#player.model.rotation.y,
			#h_rot,
			#delta * player.angular_acceleration
		#)
	#
	#return ""
#
#func exit() -> void:
	#player.aiming = false
	#anim_set("parameters/aim_transition/transition_request", "not_aiming")
#
#func handle_input(event: InputEvent) -> String:
	#if event.is_action_pressed("jump"):
		#return "Jump"
	#return ""
