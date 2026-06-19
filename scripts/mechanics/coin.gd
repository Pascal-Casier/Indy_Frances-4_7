extends Area3D

# =============================
# SAUVEGARDE
# =============================
@export var save_id : String

# =============================
# NODES
# =============================
@onready var collision_shape_3d = $CollisionShape3D
@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player = $AnimationPlayer

# =============================
# ANIMATION
# =============================
var speed : float = 2.0
var min_speed := 1.0
var max_speed := 3.0

var amplitude = 0.01
var frequency = 2.0
var time = 0.0
var initial_y = 0.0  # Position Y de départ

func _ready() -> void:
	# Validation du save_id
	if save_id == "":
		push_error("Coin '%s' has no save_id! Destroying." % name)
		queue_free()
		return
	
	# Vérifier le format (optionnel)
	if not save_id.begins_with("level"):
		push_warning("Coin '%s' has non-standard save_id: %s" % [name, save_id])
	
	# Attendre que SaveSystem soit complètement chargé
	if not SaveSystem.is_loaded:
		await SaveSystem.save_loaded  # Utilise un signal au lieu d'un timer
	
	# Vérifier si cette pièce a déjà été collectée
	if SaveSystem.world_state.has(save_id):
		if SaveSystem.world_state[save_id].get("collected", false):
			queue_free()
			return
	
	# Initialiser l'animation
	initial_y = global_position.y  # Sauvegarder la position initiale
	speed = randf_range(min_speed, max_speed)
	frequency = randf_range(min_speed, max_speed)
	
	#print("Coin '%s' ready at position y=%f" % [save_id, initial_y])

func _process(delta):
	# Rotation
	rotate_y(speed * delta)
	
	# Flottement vertical (position absolue, pas relative)
	time += delta
	var offset = sin(time * frequency) * amplitude
	global_position.y = initial_y + offset  # Pas d'accumulation !

func _on_coin_body_entered(body):
	if body.is_in_group("Player"):
		collect()

func collect():
	# Ajouter la pièce au compteur
	Global.coins += 1
	Global.emit_coins_updated()
	
	# Marquer comme collectée dans la sauvegarde
	SaveSystem.world_state[save_id] = {
		"collected": true
	}
	
	# OPTION 1: Sauvegarde différée (recommandé pour performance)
	SaveSystem.request_save()
	
	# OPTION 2: Sauvegarde immédiate (simple mais moins performant)
	# SaveSystem.save_game()
	
	#print("Coin '%s' collected! Total: %d" % [save_id, Global.coins])
	
	# Désactiver la collision
	collision_shape_3d.disabled = true
	
	# Jouer le son et l'animation
	audio_stream_player.play()
	animation_player.play("picked_up")

func _on_animation_player_animation_finished(_anim_name: String) -> void:
	queue_free()
