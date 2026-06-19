extends PlayerState

func enter() -> void:
	print("Entrée dans Movement")

func physics_update(delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Transition vers Grapple
	if (player.grapple_controller and player.grapple_controller.launched):
		return "Grapple"
	
	# Transition vers Fall si en l'air
	if not player.is_on_floor():
		player.air_movement_speed = player.movement_speed
		return "Fall"
	
	# Transition vers Attack
	if Input.is_action_just_pressed("fire") and player.can_shoot:
		return "Attack"
	
	# Logique de mouvement
	if not player.cam_h: return ""
	if not player.model: return ""
	var h_rot = player.cam_h.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
	   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		
		var direction = Vector3(
			Input.get_action_strength("left") - Input.get_action_strength("right"),
			0,
			Input.get_action_strength("forward") - Input.get_action_strength("backward")
		)
		
		player.strafe_dir = direction
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		player.direction = direction
		
		# Vérifier si on sprint
		var is_aiming = (animation_tree.get("parameters/aim_transition/current_state") if animation_tree else null) == "aiming"
		
		if player.sprinting and not is_aiming:
			player.movement_speed = player.run_speed
			anim_set("parameters/iwr_blend/blend_amount", lerp(
				(animation_tree.get("parameters/iwr_blend/blend_amount") if animation_tree else null), 
				1.0, 
				delta * player.acceleration
			))
		else:
			player.movement_speed = player.walk_speed
			anim_set("parameters/iwr_blend/blend_amount", lerp(
				(animation_tree.get("parameters/iwr_blend/blend_amount") if animation_tree else null), 
				0.0, 
				delta * player.acceleration
			))
		
		# Appliquer la vélocité HORIZONTALE (comme ligne 228 de l'ancien code)
		# On utilise lerp pour un mouvement fluide
		var target_velocity = direction * player.movement_speed
		player.velocity.x = lerp(player.velocity.x, target_velocity.x, delta * player.acceleration)
		player.velocity.z = lerp(player.velocity.z, target_velocity.z, delta * player.acceleration)
		# La composante Y est gérée par la gravité dans le _physics_process principal
		
		# Rotation du modèle
		if not is_aiming:
			player.model.rotation.y = lerp_angle(
				player.model.rotation.y,
				atan2(direction.x, direction.z),
				delta * player.angular_acceleration
			)
		else:
			player.model.rotation.y = lerp_angle(
				player.model.rotation.y,
				h_rot,
				delta * player.angular_acceleration
			)
		
		# Strafe animation
		var strafe = lerp(player.strafe, player.strafe_dir, delta * player.acceleration)
		player.strafe = strafe
		anim_set("parameters/strafe/blend_position", Vector2(-strafe.x, strafe.z))
		
		return ""
	else:
		# Plus d'input de mouvement
		return "Idle"

func handle_input(event: InputEvent) -> String:
	if event.is_action_pressed("jump"):
		return "Jump"
	if event.is_action_pressed("aim"):
		return "Aim"
	return ""
