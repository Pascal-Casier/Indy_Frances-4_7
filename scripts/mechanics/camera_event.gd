extends Camera3D

@export var door_nbr: int = -1
@export var view_duration: float = 2.0
@export var auto_switch_back: bool = true
@export var transition_duration: float = 1.0  # Durée de la transition
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_CUBIC

var original_camera: Camera3D
var tween: Tween
var initial_transform: Transform3D
var target_transform: Transform3D  # Position/rotation finale de la caméra event
var player = null

func _ready() -> void:
	current = false
	# Sauvegarde la transform de la caméra event telle que positionnée dans le niveau
	target_transform = global_transform
	Global.open_door_gate.connect(activate)

func activate(nbr: int) -> void:
	if door_nbr != nbr:
		return
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.can_move = false
	# Récupère la caméra du joueur
	original_camera = get_tree().get_nodes_in_group("PlayerCamera")[0]
	if not original_camera:
		return
	
	# Sauvegarde la transform initiale du joueur
	initial_transform = original_camera.global_transform
	
	# Active cette caméra et la positionne à la position du joueur
	current = true
	global_transform = initial_transform
	
	# Crée le tween pour la transition
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	
	# Anime vers la position/rotation définie dans le niveau
	tween.tween_property(self, "global_transform", target_transform, transition_duration)
	
	# Attend la fin de la transition
	await tween.finished
	
	# Attend la durée de visualisation
	if auto_switch_back:
		await get_tree().create_timer(view_duration).timeout
		deactivate()

func deactivate() -> void:
	if not original_camera or not is_instance_valid(original_camera):
		return
	
	# Animation de retour
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	
	# Retour à la position initiale
	tween.tween_property(self, "global_transform", initial_transform, transition_duration)
	
	await tween.finished
	
	# Réactive la caméra du joueur
	original_camera.current = true
	if player:
		player.can_move = true
		player = null
		









#extends Camera3D
#
#@export var door_nbr: int = -1
#@export var view_duration: float = 2.0
#@export var auto_switch_back: bool = true
#
#var original_camera: Camera3D
#
#func _ready() -> void:
	## La caméra n'est pas active par défaut
	#current = false
	#
	## Connexion au signal global
	#Global.open_door_gate.connect(activate)
#
#func activate(nbr) -> void:
	#if door_nbr != nbr:
		#return
	## Sauvegarde la caméra actuelle
	#original_camera = get_tree().get_nodes_in_group("PlayerCamera")[0]
	#
	## Active cette caméra
	#current = true
	#
	## Retour automatique si activé
	#if auto_switch_back:
		#await get_tree().create_timer(view_duration).timeout
		#deactivate()
#
#func deactivate() -> void:
	## Retour à la caméra précédente
	#if original_camera and is_instance_valid(original_camera):
		#original_camera.current = true
