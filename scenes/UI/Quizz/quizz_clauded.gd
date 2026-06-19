extends Control

signal success(door_number: int)
signal kill_parent

# === CONSTANTES ===
const TIME_PER_QUESTION := 10
const FEEDBACK_DURATION := 2.0
const PASSING_SCORE_RATIO := 0.7
const POINTS_PER_SECOND := 10

const COLOR_CORRECT := Color("4de30a")
const COLOR_NORMAL := Color("ffffff")

# === RÉFÉRENCES UI ===
@onready var panel = $MarginContainer/Panel
@onready var score_panel = $MarginContainer/ScorePanel
@onready var question = $MarginContainer/Panel/VBoxContainer/HBoxContainer/LblQuestion
@onready var btn_audio = $MarginContainer/Panel/VBoxContainer/HBoxContainer/btnAudio
@onready var choiceA = $MarginContainer/Panel/VBoxContainer/GridContainer/Button1
@onready var choiceB = $MarginContainer/Panel/VBoxContainer/GridContainer/Button2
@onready var choiceC = $MarginContainer/Panel/VBoxContainer/GridContainer/Button3
@onready var choiceD = $MarginContainer/Panel/VBoxContainer/GridContainer/Button4
@onready var lbl_score_2 = $MarginContainer/ScorePanel/VBoxContainer/lblScore2
@onready var lbl_bravo = $MarginContainer/ScorePanel/VBoxContainer/Control/lblBravo
@onready var btn_recommencer = $MarginContainer/ScorePanel/VBoxContainer/btnRecommencer
@onready var grid_container = $MarginContainer/Panel/VBoxContainer/GridContainer
@onready var explications: TextureRect = $MarginContainer/Panel/ColorRect
@onready var timer: Timer = %Timer
@onready var lbl_time: Label = %lblTime
@onready var audio = $AudioStreamPlayer
@onready var correct_sound = $CorrectSound
@onready var incorrect_sound = $IncorrectSound

# === EXPORTS ===
@export var quizz: Array[Questions]
@export var door_number: int = 0

# === VARIABLES D'ÉTAT ===
var running_question := 0
var score := 0
var time_left := 0
var score_total := 0
var is_processing_answer := false

# === PROPRIÉTÉS CALCULÉES ===
var last_question_index: int:
	get: return quizz.size() - 1

var total_questions: int:
	get: return quizz.size()

var passing_score: int:
	get: return ceil(total_questions * PASSING_SCORE_RATIO)


func _ready() -> void:
	z_index = 2
	_initialize_quiz()
	explications.hide()


func _initialize_quiz() -> void:
	"""Initialise ou réinitialise le quiz"""
	quizz.shuffle()
	running_question = 0
	score = 0
	score_total = 0
	render_question()


func start_new_quizz() -> void:
	"""Démarre un nouveau quiz (appelé après recommencer)"""
	explications.hide()
	_initialize_quiz()


func render_question() -> void:
	"""Affiche la question courante"""
	if running_question >= total_questions:
		end_test()
		return
	
	explications.hide()
	_reset_timer()
	
	var q := quizz[running_question]
	question.text = q.question
	choiceA.text = q.choiceA
	choiceB.text = q.choiceB
	choiceC.text = q.choiceC
	choiceD.text = q.choiceD
	
	_shuffle_buttons()
	_setup_audio(q)
	_enable_buttons()
	
	$MarginContainer/Panel/ColorRect/Explications.text = q.explications


func _reset_timer() -> void:
	"""Réinitialise et démarre le timer"""
	time_left = TIME_PER_QUESTION
	lbl_time.text = str(time_left)
	timer.start()


func _shuffle_buttons() -> void:
	"""Mélange l'ordre des boutons de réponse"""
	var buttons := grid_container.get_children()
	buttons.shuffle()
	
	for button in buttons:
		grid_container.remove_child(button)
	
	for button in buttons:
		grid_container.add_child(button)


func _setup_audio(question_data: Questions) -> void:
	"""Configure l'audio pour la question si disponible"""
	if question_data.audiostream != null:
		btn_audio.visible = true
		audio.stream = question_data.audiostream
	else:
		btn_audio.visible = false


func _enable_buttons(enabled: bool = true) -> void:
	"""Active ou désactive tous les boutons de réponse"""
	for button in grid_container.get_children():
		button.disabled = not enabled


func check_answer(answer: String, _btn_name: String) -> void:
	"""Vérifie la réponse et gère la progression"""
	if is_processing_answer:
		return
	
	is_processing_answer = true
	timer.stop()
	_enable_buttons(false)
	
	var is_correct := answer == quizz[running_question].correct
	
	if is_correct:
		correct_sound.play()
		score += 1
		score_total += time_left * POINTS_PER_SECOND
	else:
		incorrect_sound.play()
	
	await show_correct_answer()
	await get_tree().create_timer(FEEDBACK_DURATION).timeout
	
	_enable_buttons()
	is_processing_answer = false
	
	_next_question()


func _next_question() -> void:
	"""Passe à la question suivante ou termine le quiz"""
	running_question += 1
	
	if running_question <= last_question_index:
		render_question()
	else:
		end_test()


func show_correct_answer() -> void:
	"""Affiche la bonne réponse en vert"""
	var correct_button := _get_correct_button()
	if correct_button:
		correct_button.modulate = COLOR_CORRECT
	
	await get_tree().create_timer(FEEDBACK_DURATION).timeout
	
	_reset_button_colors()


func _get_correct_button() -> Button:
	"""Retourne le bouton correspondant à la bonne réponse"""
	match quizz[running_question].correct:
		"a": return choiceA
		"b": return choiceB
		"c": return choiceC
		"d": return choiceD
	return null


func _reset_button_colors() -> void:
	"""Remet les couleurs normales des boutons"""
	choiceA.modulate = COLOR_NORMAL
	choiceB.modulate = COLOR_NORMAL
	choiceC.modulate = COLOR_NORMAL
	choiceD.modulate = COLOR_NORMAL


# === HANDLERS DES BOUTONS ===
func _on_Button1_pressed() -> void:
	check_answer("a", choiceA.text)

func _on_Button2_pressed() -> void:
	check_answer("b", choiceB.text)

func _on_Button3_pressed() -> void:
	check_answer("c", choiceC.text)

func _on_Button4_pressed() -> void:
	check_answer("d", choiceD.text)


func end_test() -> void:
	"""Affiche l'écran de fin avec les résultats"""
	explications.hide()
	panel.visible = false
	score_panel.visible = true
	
	lbl_score_2.text = "Score : %d" % score_total
	%lblScore3.text = "%d réponses / %d" % [score, total_questions]
	
	var has_passed := score >= passing_score
	
	if has_passed:
		lbl_bravo.text = "Félicitations !"
		btn_recommencer.text = "Retour au jeu"
	else:
		lbl_bravo.text = "Insuffisant !"
		btn_recommencer.text = "Recommencer"


func _on_btn_recommencer_pressed() -> void:
	"""Gère le bouton recommencer/retour"""
	score_panel.visible = false
	panel.visible = true
	
	var has_passed := score >= passing_score
	
	if has_passed:
		_return_to_game()
	else:
		start_new_quizz()


func _return_to_game() -> void:
	"""Retourne au jeu après réussite du quiz"""
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	kill_parent.emit()
	start_new_quizz()  # Prépare le quiz pour la prochaine fois
	
	hide()
	z_index = -1
	success.emit(door_number)


func begin_quizz() -> void:
	"""Démarre le quiz (appelé depuis l'extérieur)"""
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_btn_exit_pressed() -> void:
	"""Ferme le quiz"""
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	hide()


func _on_btn_audio_pressed() -> void:
	"""Joue l'audio de la question"""
	audio.play()


func show_explications() -> void:
	"""Affiche le panneau d'explications"""
	explications.show()


func _on_button_ok_pressed() -> void:
	"""Ferme les explications et continue"""
	explications.hide()
	_enable_buttons()
	_next_question()


func _on_visibility_changed() -> void:
	"""Gère la pause du jeu selon la visibilité"""
	if not is_inside_tree() or not get_tree():
		return
	
	if visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_timer_timeout() -> void:
	"""Gère l'expiration du timer"""
	time_left -= 1
	lbl_time.text = str(time_left)
	
	if time_left <= 0:
		timer.stop()
		_handle_timeout()


func _handle_timeout() -> void:
	"""Gère le cas où le temps est écoulé"""
	if is_processing_answer:
		return
	
	is_processing_answer = true
	_enable_buttons(false)
	
	incorrect_sound.play()
	await show_correct_answer()
	show_explications()
	
	is_processing_answer = false
