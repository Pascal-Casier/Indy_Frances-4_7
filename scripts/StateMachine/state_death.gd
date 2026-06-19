extends PlayerState

var is_respawning := false

func enter() -> void:
	print("Entrée dans Death")
	is_respawning = true
	var collision = player.get_node_or_null("CollisionShape3D")
	if collision: collision.disabled = true
	if animation_tree:
		anim_set("parameters/die/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	await player.get_tree().create_timer(4.5).timeout
	
	CheckpointManager.respawn_player()
	if collision: collision.disabled = false
	Global.health = 100
	Global.emit_health_update()
	is_respawning = false

func physics_update(_delta: float) -> String:
	# Désactiver tout mouvement pendant la mort
	player.velocity = Vector3.ZERO
	
	# Retourner à Idle après le respawn
	if not is_respawning:
		return "Idle"
	
	return ""

func exit() -> void:
	is_respawning = false
