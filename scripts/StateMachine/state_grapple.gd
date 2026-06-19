extends PlayerState

func enter() -> void:
	print("Entrée dans Grapple")
	anim_set("parameters/jump_transition/transition_request", "jumping")

func physics_update(delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Rotation du modèle
	if not player.cam_h: return ""
	if not player.model: return ""
	var h_rot = player.cam_h.global_transform.basis.get_euler().y
	player.model.rotation.y = lerp_angle(
		player.model.rotation.y,
		h_rot,
		delta * player.angular_acceleration
	)
	
	# La vélocité est gérée par le GrappleController
	# On applique juste une légère gravité
	if not player.is_on_floor():
		player.vertical_velocity -= (player.gravity * 0.2) * delta
		player.vertical_velocity = max(player.vertical_velocity, -5.0)
	else:
		player.vertical_velocity = 0
	
	# Appliquer uniquement la composante verticale
	player.velocity.y += player.vertical_velocity * delta
	
	# Sortir du grapple quand il est terminé
	if not (player.grapple_controller and player.grapple_controller.launched):
		if player.is_on_floor():
			if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
			   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
				return "Movement"
			else:
				return "Idle"
		else:
			return "Fall"
	
	return ""

func exit() -> void:
	pass
