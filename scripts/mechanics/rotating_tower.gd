extends CharacterBody3D

@export var pause_duration := 3.0  # Durée de la pause en secondes
@export var time_of_rotation : float = 2.0
@export var is_automatic :bool = false
@export var door_nbr : int = 0
#@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tronc: MeshInstance3D = $MeshInstance3D
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
var tween: Tween
const WALL_MOVING = preload("res://assets/sounds/sfx/chains_soundFX.mp3")
var current_rotation = 0.0

func _ready():
	Global.open_door_gate.connect(trigger_rotation)
	if is_automatic:
		start_rotation_sequence()

func start_rotation_sequence():
	rotate_quarter_turn()
	
func rotate_quarter_turn():
	audio_stream_player.stream = WALL_MOVING
	audio_stream_player.play()
	tween = create_tween()
	
	var target_rotation = current_rotation + 90.0
	tween.tween_method(apply_rotation, current_rotation, target_rotation, time_of_rotation).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(start_pause)

func apply_rotation(angle_degrees: float):
	self.rotation.y = deg_to_rad(angle_degrees)
func start_pause():
	tween = create_tween()
	tween.tween_interval(pause_duration)
	tween.tween_callback(on_pause_complete)

func on_pause_complete():
	current_rotation += 90.0
	# Réinitialiser à 0 après un tour complet
	if current_rotation >= 360.0:
		current_rotation = 0.0
	# Continuer avec le prochain quart de tour
	rotate_quarter_turn()

func do_quarter_turn():
	# Éviter de lancer plusieurs rotations simultanément
	if tween && tween.is_valid():
		return
	audio_stream_player.stream = WALL_MOVING
	audio_stream_player.play()
	tween = create_tween()
	
	var start_rotation = self.rotation.y
	var target_rotation = start_rotation + deg_to_rad(90.0)
	
	tween.tween_method(apply_rotation_once, rad_to_deg(start_rotation), rad_to_deg(target_rotation), time_of_rotation).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

func apply_rotation_once(angle_degrees: float):
	self.rotation.y = deg_to_rad(angle_degrees)

# Fonction pour déclencher la rotation (à appeler depuis l'extérieur)
func trigger_rotation(door_nb):
	if door_nbr == door_nb:
		do_quarter_turn()
