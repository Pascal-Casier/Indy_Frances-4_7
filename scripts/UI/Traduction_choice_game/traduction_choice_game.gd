# res://scripts/quiz_manager.gd
extends Control

signal game_over

# ── Références aux nœuds ──────────────────────────────────────────────────────
@onready var original_label:   RichTextLabel = %OriginalLabel
@onready var answer_a_label:   RichTextLabel = %AnswerALabel
@onready var answer_b_label:   RichTextLabel = %AnswerBLabel
@onready var answer_a_button:  Button        = %AnswerA
@onready var answer_b_button:  Button        = %AnswerB
@onready var feedback_label:   Label         = %FeedbackLabel
@onready var progress_label:   Label         = %ProgressLabel
@onready var anim_player:      AnimationPlayer = $AnimationPlayer
@onready var id_picture:       TextureRect     = %IDPicture
@onready var audio_player:     AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_correct: AudioStreamPlayer = $AudioStreamPlayerCorrect
const CORRECT_SOUND = preload("res://assets/sounds/sfx/correct_sound.mp3")
const INCORRECT_SOUND = preload("res://assets/sounds/sfx/incorrect_sound.mp3")
# ── Export ────────────────────────────────────────────────────────────────────
@export var quiz_data: QuizData  ## Glissez votre ressource QuizData ici

# ── État interne ──────────────────────────────────────────────────────────────
var _current_index: int = 0
var _correct_is_on_left: bool = true   # true = réponse correcte sur le bouton A
var _correct_count: int = 0            # nombre de bonnes réponses

# ── Seuil de réussite ─────────────────────────────────────────────────────────
const SUCCESS_THRESHOLD: float = 0.70  # 70 %

# ── Couleurs de feedback ──────────────────────────────────────────────────────
const COLOR_CORRECT: Color   = Color("4caf50")
const COLOR_WRONG: Color     = Color("f44336")
const COLOR_DEFAULT: Color   = Color("eceff1")
const COLOR_HIGHLIGHT: Color = Color("ffd54f")


func _ready() -> void:
	if quiz_data == null or quiz_data.entries.is_empty():
		push_error("QuizManager : aucune QuizData assignée ou liste vide.")
		return
	#start_quiz()


# ── Démarrage / Redémarrage ───────────────────────────────────────────────────
func start_quiz() -> void:
	_current_index = 0
	_correct_count = 0
	answer_a_button.visible = true
	answer_b_button.visible = true
	_load_entry(_current_index)


# ── Chargement d'une entrée ───────────────────────────────────────────────────
func _load_entry(index: int) -> void:
	var entry: DialogueEntry = quiz_data.entries[index]

	# Mise à jour du compteur
	progress_label.text = "%d / %d" % [index + 1, quiz_data.entries.size()]

	# Affichage de la phrase originale (BBCode activé)
	original_label.text = entry.original_text

	# Mélange aléatoire des réponses gauche/droite
	_correct_is_on_left = (randi() % 2 == 0)

	if _correct_is_on_left:
		answer_a_label.text = entry.correct_translation
		answer_b_label.text = entry.wrong_translation
	else:
		answer_a_label.text = entry.wrong_translation
		answer_b_label.text = entry.correct_translation

	# Remise à zéro visuelle
	feedback_label.text = ""
	_reset_button_colors()
	answer_a_button.disabled = false
	answer_b_button.disabled = false

	# Photo du locuteur (cachée si aucune image assignée)
	if entry.speaker_picture != null:
		id_picture.texture = entry.speaker_picture
		id_picture.visible = true
	else:
		id_picture.texture = null
		id_picture.visible = false

	# Audio de la phrase (joué automatiquement si assigné)
	audio_player.stop()
	if entry.spoken_audio != null:
		audio_player.stream = entry.spoken_audio
		audio_player.play()


# ── Gestionnaires de clics ────────────────────────────────────────────────────
func _on_answer_a_pressed() -> void:
	_check_answer(_correct_is_on_left, answer_a_button, answer_b_button)

func _on_answer_b_pressed() -> void:
	_check_answer(not _correct_is_on_left, answer_b_button, answer_a_button)


func _check_answer(is_correct: bool, chosen_btn: Button, other_btn: Button) -> void:
	# Désactive les deux boutons immédiatement
	answer_a_button.disabled = true
	answer_b_button.disabled = true

	if is_correct:
		_correct_count += 1
		_apply_button_color(chosen_btn, COLOR_CORRECT)
		feedback_label.text       = "✔ Correct !"
		feedback_label.modulate   = COLOR_CORRECT
		audio_stream_player_correct.stream = CORRECT_SOUND
		audio_stream_player_correct.play()
	else:
		_apply_button_color(chosen_btn, COLOR_WRONG)
		# Révèle la bonne réponse
		_apply_button_color(other_btn, COLOR_CORRECT)
		feedback_label.text       = "✘ Incorrect."
		feedback_label.modulate   = COLOR_WRONG
		audio_stream_player_correct.stream = INCORRECT_SOUND
		audio_stream_player_correct.play()

	# Passage à la suite après un délai
	await get_tree().create_timer(1.4).timeout
	_advance()


func _advance() -> void:
	_current_index += 1

	if _current_index >= quiz_data.entries.size():
		_show_end_screen()
	else:
		# Optionnel : animation de transition
		if anim_player and anim_player.has_animation("slide_in"):
			anim_player.play("slide_in")
		_load_entry(_current_index)


# ── Écran de fin ──────────────────────────────────────────────────────────────
func _show_end_screen() -> void:
	var total: int = quiz_data.entries.size()
	var score_pct: float = float(_correct_count) / float(total)
	var passed: bool = score_pct >= SUCCESS_THRESHOLD

	answer_a_button.visible = false
	answer_b_button.visible = false
	progress_label.text     = ""
	id_picture.visible      = false
	audio_player.stop()

	if passed:
		original_label.text   = "[center][b]Quiz terminé ![/b][/center]"
		feedback_label.text   = "✔ Bravo ! %d / %d (%.0f%%)" % [_correct_count, total, score_pct * 100]
		feedback_label.modulate = COLOR_CORRECT
		$TextureRect/ButtonExit.disabled = false
	else:
		original_label.text     = "[center][b]Quiz terminé ![/b][/center]"
		feedback_label.modulate = COLOR_WRONG

		# Décompte seconde par seconde
		var base_msg: String = "✘ %d / %d (%.0f%%) — Il faut au moins 70%% pour réussir." \
								% [_correct_count, total, score_pct * 100]
		for seconds_left in range(3, 0, -1):
			feedback_label.text = "%s\nRecommencer dans %d s…" % [base_msg, seconds_left]
			await get_tree().create_timer(1.0).timeout

		answer_a_button.visible = true
		answer_b_button.visible = true
		start_quiz()


# ── Utilitaires visuels ───────────────────────────────────────────────────────
func _apply_button_color(btn: Button, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color           = color
	style.corner_radius_top_left    = 8
	style.corner_radius_top_right   = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal",   style)
	btn.add_theme_stylebox_override("hover",    style)
	btn.add_theme_stylebox_override("pressed",  style)
	btn.add_theme_stylebox_override("disabled", style)


func _reset_button_colors() -> void:
	for btn in [answer_a_button, answer_b_button]:
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("pressed")
		btn.remove_theme_stylebox_override("disabled")


func _on_button_exit_pressed() -> void:
	game_over.emit()
	hide()
