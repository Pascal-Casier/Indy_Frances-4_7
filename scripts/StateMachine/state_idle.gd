extends PlayerState

func enter() -> void:
	print("Entrée dans Idle")
	player.movement_speed = 0.0
	if animation_tree:
		anim_set("parameters/iwr_blend/blend_amount", -1.0)

func physics_update(_delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Transition vers Grapple si en train de grappiner
	if (player.grapple_controller and player.grapple_controller.launched):
		return "Grapple"
	
	# Transition vers Jump si en l'air
	if not player.is_on_floor():
		player.air_movement_speed = player.movement_speed
		return "Fall"
	
	# Transition vers Attack si attaque
	if Input.is_action_just_pressed("fire") and player.can_shoot:
		return "Attack"
	
	# Transition vers Movement si input de mouvement
	if Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
	   Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		return "Movement"
	
	# Rester en Idle : arrêter le mouvement horizontal seulement
	player.velocity.x = 0.0
	player.velocity.z = 0.0
	player.strafe_dir = Vector3.ZERO
	
	return ""

func handle_input(event: InputEvent) -> String:
	if event.is_action_pressed("jump"):
		return "Jump"
	if event.is_action_pressed("aim"):
		return "Aim"
	return ""
