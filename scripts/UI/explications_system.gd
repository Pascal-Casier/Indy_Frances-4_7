extends Control

## Liste des textes affichés, un par explication
@export_multiline var textes: Array[String] = []

## Liste des fichiers audio de narration, dans le même ordre que les textes
@export var narrations: Array[AudioStream] = []

@onready var label: RichTextLabel = $TextureRect/MarginContainer/RichTextLabel
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var button_prev: Button = $TextureRect/HBoxContainer/PrevButton
@onready var button_play: Button = $TextureRect/HBoxContainer/PlayButton
@onready var button_next: Button = $TextureRect/HBoxContainer/NextButton

var index: int = 0

const TEXTE_ECOUTER := "Écouter"
const TEXTE_PAUSE := "Pause"

func _ready() -> void:
	button_prev.pressed.connect(_on_prev_pressed)
	button_play.pressed.connect(_on_play_pressed)
	button_next.pressed.connect(_on_next_pressed)
	audio_player.finished.connect(_on_audio_finished)
	_update_display()

func _on_prev_pressed() -> void:
	if index > 0:
		index -= 1
		_update_display()

func _on_next_pressed() -> void:
	if index < textes.size() - 1:
		index += 1
		_update_display()

func _on_play_pressed() -> void:
	if audio_player.playing:
		# En cours de lecture -> on met en pause
		audio_player.stream_paused = true
		button_play.text = TEXTE_ECOUTER
	elif audio_player.stream_paused:
		# En pause -> on reprend
		audio_player.stream_paused = false
		button_play.text = TEXTE_PAUSE
	else:
		# Pas encore lancé -> on démarre
		if index < narrations.size() and narrations[index] != null:
			audio_player.stream = narrations[index]
			audio_player.play()
			button_play.text = TEXTE_PAUSE

func _on_audio_finished() -> void:
	button_play.text = TEXTE_ECOUTER

func _update_display() -> void:
	if textes.is_empty():
		label.text = ""
		return

	label.text = textes[index]

	# Désactive les boutons aux bornes
	button_prev.disabled = index == 0
	button_next.disabled = index == textes.size() - 1

	# Arrête l'audio en cours quand on change d'explication
	audio_player.stop()
	audio_player.stream_paused = false
	button_play.text = TEXTE_ECOUTER

	# Désactive "Écouter" si aucun audio n'est associé
	button_play.disabled = index >= narrations.size() or narrations[index] == null


func _on_button_exit_pressed() -> void:
	hide()
