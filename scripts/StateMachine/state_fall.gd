extends PlayerState

func enter() -> void:
	print("Entrée dans Fall")
	anim_travel("parameters/JumpStateMachine/playback", "Jump_Idle")
	anim_set("parameters/jump_transition/transition_request", "jumping")

func physics_update(delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Transition vers Grapple
	if (player.grapple_controller and player.grapple_controller.launched):
		return "Grapple"
	
	# Permettre le double saut en l'air
	# (géré dans handle_input pour ne pas manquer l'event)
	
	# Glider
	if Input.is_action_pressed("glide") and Global.can_glide and player.velocity.y < 0:
		player.parapente.show()
		player.gravity = 5.0
	if Input.is_action_just_released("glide"):
		player.parapente.hide()
		player.gravity = 28.0
	
	# Ventilator effect
	if player.is_in_ventilator:
		player.gravity = -15
	else:
		if not Input.is_action_pressed("glide"):
			player.gravity = 28
	
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
		# Utiliser la vitesse capturée, ou walk_speed si on tombe sans avoir bougé
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
		player.parapente.hide()
		player.gravity = 28.0
		player.jump_number = 0
		anim_set("parameters/jump_transition/transition_request", "not_jumping")
		
		# Retourner à Movement ou Idle
		if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
		   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			return "Movement"
		else:
			return "Idle"
	
	return ""

func exit() -> void:
	player.parapente.hide()
	player.gravity = 28.0

func handle_input(event: InputEvent) -> String:
	if event.is_action_pressed("jump") and player.jump_number == 1 and player.can_double_jump:
		return "Jump"
	return ""
