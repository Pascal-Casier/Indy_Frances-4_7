extends Node3D


@export var mot_cible: String = "CHAT" # Le mot à composer
@export var door_nbr : int = -1
var progression: String = ""
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var text_2: Label3D = %Text2
@onready var text_answer: Label3D = %TextAnswer


const CORRECT_2 = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect2.ogg")
const VICTORY = preload("res://assets/sounds/musics/Victory.ogg")

func _ready():
	text_2.text = mot_cible
	progression = ""
	for cible in get_tree().get_nodes_in_group("target_letter"):
		cible.cible_touchee.connect(on_cible_touchee)

func on_cible_touchee(lettre: String):
	var attendu = mot_cible[progression.length()]
	if lettre.to_upper() == attendu:
		progression += lettre.to_upper()
		text_answer.text = progression
		audio_stream_player.stream = CORRECT_2
		audio_stream_player.play()
		if progression == mot_cible:
			Global.emit_open_door_gate(door_nbr)
			audio_stream_player.stream = VICTORY
			audio_stream_player.play()
			progression = ""
			
	else:
		progression = ""
		text_answer.text = progression
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
