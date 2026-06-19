extends PlayerState

var is_attacking := false

func enter() -> void:
	print("Entrée dans Attack")
	is_attacking = true
	
	# Tir avec la baguette
	if player.can_shoot and player.wand and player.wand.visible and player.aiming:
		player.fire()
		var shoot_audio = player.get_node_or_null("ShootAudioStreamPlayer")
		if shoot_audio: shoot_audio.play()
		if animation_tree:
			anim_set("parameters/throw/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		await player.get_tree().create_timer(0.5).timeout
		is_attacking = false
	
	# Attaque avec le fouet/épée
	elif player.can_shoot and player.sword_visible and player.is_on_floor() and player.has_found_whip:
		if player.rope_shaded: player.rope_shaded.show()
		if animation_tree:
			anim_set("parameters/slice/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		player.can_shoot = false
		
		await player.get_tree().create_timer(0.3).timeout
		if player.sword_hit: player.sword_hit.set_deferred("monitoring", true)
		player.check_whip_raycast()
		
		await player.get_tree().create_timer(0.2).timeout
		player.can_shoot = true
		if player.sword_hit: player.sword_hit.set_deferred("monitoring", false)
		
		await player.get_tree().create_timer(0.3).timeout
		if player.rope_shaded: player.rope_shaded.hide()
		is_attacking = false
	else:
		is_attacking = false

func physics_update(_delta: float) -> String:
	# Vérifier si le joueur est en vie
	if Global.health <= 0:
		return "Death"
	
	# Attendre la fin de l'attaque
	if not is_attacking:
		# Vérifier l'état après l'attaque
		if not player.is_on_floor():
			return "Fall"
		elif Input.is_action_pressed("aim"):
			return "Aim"
		elif Input.is_action_pressed("forward") or Input.is_action_pressed("backward") or \
			 Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			return "Movement"
		else:
			return "Idle"
	
	return ""

func exit() -> void:
	is_attacking = false
