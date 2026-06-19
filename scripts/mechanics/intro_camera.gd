extends Camera3D
@export var cam_travel_time : float = 5.0
@onready var player_cam := get_tree().get_nodes_in_group("PlayerCamera")[0]
@onready var player := get_tree().get_nodes_in_group("Player")[0]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	
	make_current()
	# Facultatif : désactiver les contrôles du joueur
	
	if player.has_method("disable_controls"):
		player.disable_controls()
	
	#await get_tree().process_frame  # Laisse le temps au SpringArm de se mettre à jour
	await get_tree().create_timer(3).timeout
	audio_stream_player.play()
	# Tween vers la position et rotation de la PlayerCamera
	var target_pos = player_cam.global_transform.origin
	var target_rot = player_cam.global_transform.basis.get_euler()
	var current_rot = global_transform.basis.get_euler()
	
	# Créer deux tweens séparés pour les faire jouer en parallèle
	var position_tween = create_tween()
	var rotation_tween = create_tween()
	
	# Tween pour la position
	position_tween.tween_property(self, "global_position", target_pos, cam_travel_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# Tween pour la rotation
	rotation_tween.tween_method(
		func(value):
			global_transform = Transform3D(Basis.from_euler(value), global_transform.origin),
		current_rot,
		target_rot,
		cam_travel_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Attendre que l'un des tweens soit terminé (ils ont la même durée)
	#await position_tween.finished
	await audio_stream_player.finished
	# Callback à la fin
	player_cam.make_current()
	if player.has_method("enable_controls"):
		player.enable_controls()
	queue_free()  # Supprimer cette caméra une fois l'intro terminée
