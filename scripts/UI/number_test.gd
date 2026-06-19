extends Control

signal success
# ──────────────────────────────────────────────
# À remplir dans l'inspecteur
# ──────────────────────────────────────────────
@export var sound_list: Array[AudioStream] = []
@export var answers: Array[String] = []  # ex: ["3", "42", "7", "156"]

# Nœuds — adapte les chemins à ta scène
@onready var audio_player:    AudioStreamPlayer = %AudioStreamPlayer
@onready var play_button:     Button            = %PlayButton
@onready var validate_button: Button            = %ValidateButton
@onready var delete_button:   Button            = %DeleteButton
@onready var input_label:     Label             = %InputLabel    # saisie du joueur
@onready var feedback_label:  Label             = %FeedbackLabel# "Bravo" / "Erreur"
@onready var digit_grid:      GridContainer     = %GridContainer
@onready var fx_audio_stream_player: AudioStreamPlayer = %AudioStreamPlayerFX
@onready var replay_btn: Button = %replayBtn
@onready var exit_btn: Button = %ExitBtn
@onready var ending_container: HBoxContainer = %EndingContainer


const CORRECT_SOUND = preload("res://assets/sounds/sfx/correct_sound.mp3")
const INCORRECT_SOUND = preload("res://assets/sounds/sfx/incorrect_sound.mp3")

# ──────────────────────────────────────────────
# État interne
# ──────────────────────────────────────────────
var current_index: int  = 0
var player_input:  String = ""
var can_interact:  bool = true   # bloqué pendant la transition entre rounds

# ══════════════════════════════════════════════
func _ready() -> void:
	_connect_digit_buttons()
	play_button.pressed.connect(_on_play_pressed)
	validate_button.pressed.connect(_on_validate_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	replay_btn.pressed.connect(_on_replay_btn_pressed)
	exit_btn.pressed.connect(_on_exit_btn_pressed)
	#_load_round()

# ──────────────────────────────────────────────
# Connecte tous les boutons chiffres du GridContainer
# Le texte de chaque bouton DOIT être son chiffre ("0".."9")
# ──────────────────────────────────────────────
func _connect_digit_buttons() -> void:
	for child in digit_grid.get_children():
		if child is Button:
			child.pressed.connect(_on_digit_pressed.bind(child.text))

# ──────────────────────────────────────────────
# Prépare un nouveau round
# ──────────────────────────────────────────────
func _load_round() -> void:
	player_input = ""
	can_interact  = true
	feedback_label.text = ""
	_update_input_display()
	_set_digit_buttons_disabled(false)
	validate_button.disabled = false
	delete_button.disabled   = false

	if current_index >= sound_list.size():
		_end_game()
		return

	audio_player.stream = sound_list[current_index]
	# Joue automatiquement le son au début de chaque round
	audio_player.play()

# ──────────────────────────────────────────────
# Rejoue le son du round actuel
# ──────────────────────────────────────────────
func _on_play_pressed() -> void:
	if audio_player.stream and can_interact:
		audio_player.play()

# ──────────────────────────────────────────────
# Ajoute un chiffre à la saisie
# ──────────────────────────────────────────────
func _on_digit_pressed(digit: String) -> void:
	if not can_interact:
		return
	player_input += digit
	_update_input_display()

# ──────────────────────────────────────────────
# Efface le dernier chiffre saisi
# ──────────────────────────────────────────────
func _on_delete_pressed() -> void:
	if not can_interact or player_input.is_empty():
		return
	player_input = player_input.left(player_input.length() - 1)
	_update_input_display()

# ──────────────────────────────────────────────
# Valide la réponse du joueur
# ──────────────────────────────────────────────
func _on_validate_pressed() -> void:
	if not can_interact or player_input.is_empty():
		return

	var expected: String = answers[current_index]

	if player_input == expected:
		feedback_label.text = "✅ Bravo !"
		can_interact = false
		_set_digit_buttons_disabled(true)
		validate_button.disabled = true
		delete_button.disabled   = true
		fx_audio_stream_player.stream = CORRECT_SOUND
		fx_audio_stream_player.play()
		# Courte pause avant le round suivant
		await get_tree().create_timer(1.5).timeout
		current_index += 1
		_load_round()
	else:
		feedback_label.text = "❌ Essaie encore !"
		player_input = ""
		fx_audio_stream_player.stream = INCORRECT_SOUND
		fx_audio_stream_player.play()
		_update_input_display()

# ──────────────────────────────────────────────
# Affichage de la saisie en cours
# ──────────────────────────────────────────────
func _update_input_display() -> void:
	input_label.text = player_input if not player_input.is_empty() else "_"

# ──────────────────────────────────────────────
# Active / désactive tous les boutons chiffres
# ──────────────────────────────────────────────
func _set_digit_buttons_disabled(disabled: bool) -> void:
	for child in digit_grid.get_children():
		if child is Button:
			child.disabled = disabled

# ──────────────────────────────────────────────
# Fin de jeu : plus aucun son dans la liste
# ──────────────────────────────────────────────
func _end_game() -> void:
	feedback_label.text = "🎉 Félicitations, tu as tout terminé !"
	play_button.disabled     = true
	validate_button.disabled = true
	delete_button.disabled   = true
	_set_digit_buttons_disabled(true)
	#await get_tree().create_timer(1.5).timeout
	success.emit()
	ending_container.show()

func _on_replay_btn_pressed() -> void:
	current_index = 0
	_load_round()

func _on_exit_btn_pressed() -> void:
	ending_container.hide()
	current_index = 0
	hide()
