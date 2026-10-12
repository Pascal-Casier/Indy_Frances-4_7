class_name MovingTower3D
extends Node3D

@export var door_nbr : int = -1
@export_category("Paramètres de mouvement")
## Distance verticale parcourue par la tour (en mètres)
@export var move_distance: float = 3.0
## Temps nécessaire pour effectuer un trajet (en secondes)
@export var move_time: float = 1.0

@export_category("Limites")
## Nombre maximum de montées consécutives avant de devoir redescendre
@export var max_consecutive_climbs: int = 3

@export_category("Audio")
## Fichier audio du son de mouvement
@export var move_sound: AudioStream

var audio_player: AudioStreamPlayer3D

# Variables internes
var is_moving: bool = false
var current_climbs: int = 0
var is_descending: bool = false
var initial_y: float = 0.0

func _ready() -> void:
	initial_y = position.y
	Global.open_door_gate.connect(open_door)
	# Configuration du lecteur audio 3D
	audio_player = AudioStreamPlayer3D.new()
	if move_sound:
		audio_player.stream = move_sound
	add_child(audio_player)

## Fonction appelée lors de la réception du signal open_door(nbr)
func open_door(nbr: int) -> void:
	if is_moving and door_nbr != nbr:
		return
		
	is_moving = true
	
	# Détermine si la tour doit monter ou descendre
	if not is_descending:
		current_climbs += 1
		
		# Si on atteint le quota de montées, on active le mode descente pour le prochain signal
		if current_climbs >= max_consecutive_climbs:
			is_descending = true
	else:
		current_climbs -= 1
		
		# Si on a redescendu toutes les fois qu'on était monté, on repasse en mode montée
		if current_climbs <= 0:
			is_descending = false
	
	# Calcule la position cible relative à la position de départ (initial_y)
	# On multiplie par current_climbs pour que la hauteur s'ajuste dynamiquement à chaque palier
	var target_y = initial_y + (current_climbs * move_distance)
	
	# Lance le son
	if audio_player.stream:
		audio_player.play()
	
	# Animation fluide avec le Tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", target_y, move_time)
	
	await tween.finished
	
	audio_player.stop()
	is_moving = false
