extends PlayerState

func enter() -> void:
	print("Entrée dans Jump")
	
	# Capturer la vitesse de mouvement actuelle pour la conserver en l'air
	player.air_movement_speed = player.movement_speed
	
	var can_coyote_jump = not player.coyote_timer.is_stopped()
	
	if player.is_on_floor() or can_coyote_jump:
		if can_coyote_jump:
			player.coyote_timer.stop()
		
		player.jump_number = 1
		player.jumping = true  # flag pour que _physics_process ne met pas vertical_velocity à 0
		player.vertical_velocity = player.jump_magnitude
		anim_set("parameters/jump_transition/transition_request", "jumping")
		anim_travel("parameters/JumpStateMachine/playback", "Jump_Start")
		player.jump_buffer_timer.stop()
	# Double saut
	elif player.jump_number == 1 and player.can_double_jump:
		player.jump_number = 0
		player.jumping = true  # même flag
		player.vertical_velocity = player.jump_magnitude
		anim_set("parameters/jump_transition/transition_request", "jumping")
		anim_travel("parameters/JumpStateMachine/playback", "Jump_Start")
		player.jump_buffer_timer.stop()

func physics_update(delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Transition vers Grapple
	if (player.grapple_controller and player.grapple_controller.launched):
		return "Grapple"
	
	# Gérer le mouvement horizontal en l'air
	if not player.cam_h: return ""
	var h_rot = player.cam_h.global_transform.basis.get_euler().y
	var direction = player.direction
	var air_speed = 0.0  # Par défaut, pas de mouvement
	
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
	   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		direction = Vector3(
			Input.get_action_strength("left") - Input.get_action_strength("right"),
			0,
			Input.get_action_strength("forward") - Input.get_action_strength("backward")
		)
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		player.direction = direction
		# Utiliser la vitesse capturée, ou walk_speed si on a sauté sans bouger
		air_speed = max(player.air_movement_speed, player.walk_speed)
	else:
		# Pas d'input : on ralentit progressivement
		air_speed = 0.0
	
	# Appliquer le mouvement horizontal en l'air
	var target_velocity = direction * air_speed
	player.velocity.x = lerp(player.velocity.x, target_velocity.x, delta * player.acceleration)
	player.velocity.z = lerp(player.velocity.z, target_velocity.z, delta * player.acceleration)
	
	# Rotation du modèle vers la direction de mouvement
	if player.model and direction.length() > 0.1:
		player.model.rotation.y = lerp_angle(
			player.model.rotation.y,
			atan2(direction.x, direction.z),
			delta * player.angular_acceleration
		)
	
	# Si on atterrit
	if player.is_on_floor():
		player.jumping = false
		player.jump_number = 0
		anim_set("parameters/jump_transition/transition_request", "not_jumping")
		
		# Retourner à Movement ou Idle selon l'input
		if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
		   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			return "Movement"
		else:
			return "Idle"
	
	# Si on tombe (vélocité négative)
	if player.vertical_velocity < 0:
		return "Fall"
	
	return ""

func exit() -> void:
	pass
