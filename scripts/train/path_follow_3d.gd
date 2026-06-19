extends PathFollow3D
class_name TrainController

@export var max_speed: float = 10.0
@export var acceleration: float = 2.0
@export var deceleration: float = 3.0
@export var speed_increment: float = 1.0  # Augmentation de vitesse par pression de touche
@export var time_to_go : int = 30
@export var speed_label: Label  # Référence au Label pour afficher la vitesse
@export var can_manual_change_speed : bool = false

@export_group("Audio Settings")
@export var min_pitch: float = 0.5  # Pitch au ralenti
@export var max_pitch: float = 2.0  # Pitch à vitesse max
@export var audio_fade_speed: float = 2.0  # Vitesse de transition du volume
@export var idle_volume_db: float = -10.0  # Volume quand immobile
@export var max_volume_db: float = 0.0  # Volume à pleine vitesse
@onready var timer: Timer = %TimerToGo
@onready var label_timeto_go: Label = %LabelTimetoGo
@onready var audio_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var audio_stream_player_klaxon: AudioStreamPlayer = %AudioStreamPlayerKlaxon

var current_speed: float = 0.0
var target_speed: float = 0.0

func _ready():
	target_speed = 0.0
	current_speed = 0.0
	if audio_player:
		audio_player.pitch_scale = min_pitch
		audio_player.volume_db = idle_volume_db
		# Démarrer le son en boucle si ce n'est pas déjà fait
		if not audio_player.playing:
			audio_player.play()

func _process(delta):
	# Gestion de l'accélération/décélération progressive
	if current_speed < target_speed:
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, target_speed, deceleration * delta)
	
	# Mouvement le long du path
	progress += current_speed * delta
	
	# Mise à jour de l'affichage de vitesse
	update_speed_display()
	# Mise à jour du son
	update_audio(delta)
	# Contrôles manuels
	handle_input()

func update_audio(delta: float):
	
	if not audio_player:
		return
	
	# Calcul du pourcentage de vitesse (0.0 à 1.0)
	var speed_ratio = get_speed_percentage()
	
	# Modulation du pitch (interpolation linéaire entre min et max)
	var target_pitch = lerp(min_pitch, max_pitch, speed_ratio)
	audio_player.pitch_scale = target_pitch
	
	# Modulation du volume (optionnel)
	var target_volume = lerp(idle_volume_db, max_volume_db, speed_ratio)
	audio_player.volume_db = move_toward(
		audio_player.volume_db, 
		target_volume, 
		audio_fade_speed * delta
	)
	
	# Arrêter le son si complètement immobile (optionnel)
	if current_speed <= 0.01 and target_speed <= 0.01:
		if audio_player.volume_db < -30:
			audio_player.stop()
	else:
		if not audio_player.playing:
			audio_player.play()

func handle_input():
	if not can_manual_change_speed:
		return
	# Augmenter la vitesse (touche haut)
	if Input.is_action_just_pressed("ui_up"):
		increase_speed()
	
	# Diminuer la vitesse (touche bas)
	if Input.is_action_just_pressed("ui_down"):
		decrease_speed()
	
	# Arrêt d'urgence (par exemple avec la touche espace)
	if Input.is_action_just_pressed("ui_accept"):
		emergency_stop()

func increase_speed():
	audio_stream_player_klaxon.pitch_scale = 1
	audio_stream_player_klaxon.play()
	target_speed = clamp(target_speed + speed_increment, 0.0, max_speed)

func decrease_speed():
	audio_stream_player_klaxon.pitch_scale = 0.75
	audio_stream_player_klaxon.play()
	target_speed = clamp(target_speed - speed_increment, 0.0, max_speed)

func set_speed_percentage(percentage: float):
	#"""Définit la vitesse en pourcentage (0.0 à 1.0)"""
	target_speed = clamp(percentage, 0.0, 1.0) * max_speed

func emergency_stop():
	target_speed = 0.0

func get_speed_percentage() -> float:
	return current_speed / max_speed if max_speed > 0 else 0.0

func update_speed_display():
	if speed_label:
		# Option 1 : Affichage simple en km/h (ou unités de vitesse)
		speed_label.text = "Vitesse: %.0f km/h" % current_speed
		# Option 2 : Avec pourcentage (décommenter si préféré)
		# var percentage = get_speed_percentage() * 100
		# speed_label.text = "Vitesse: %.0f km/h (%.0f%%)" % [current_speed, percentage]

# Fonction pour changement de vitesse externe (garde la compatibilité)
func change_speed(multiplier: float) -> void:
	target_speed = clamp(target_speed * multiplier, 0.0, max_speed)

func _on_target_2_inform_text(title: Variant) -> void: 
	if title == "test":
		set_speed_percentage(0.8)  # 80% de la vitesse max
	else:
		set_speed_percentage(0.2)  # 20% de la vitesse max
		

func _on_ui_layer_conjugation_right_answer(is_correct: bool) -> void:
	if is_correct:
		increase_speed()
	else:
		decrease_speed()


func _on_timer_to_go_timeout() -> void:
	time_to_go -= 1
	label_timeto_go.text = "Temps pour arriver : " + str(time_to_go)
	if time_to_go == 0 :
		timer.stop()
		emergency_stop()
