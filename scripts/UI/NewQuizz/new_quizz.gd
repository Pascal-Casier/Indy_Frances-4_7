# quiz_manager.gd
extends Control

signal game_over

@export var door_nbr := -1
@export var questions: Array[QuestionResource] = []
@export var time_per_question: float = 15.0  # 15 secondes par question
const CORRECTSOUND = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECTSOUND = preload("res://assets/sounds/sfx/incorrect2.ogg")
@onready var question_label = %QuestionLabel
@onready var audio_button = %AudioButton
@onready var option_buttons = [
	%Option1,
	%Option2,
	%Option3,
	%Option4
]
@onready var score_panel = %ScorePanel
@onready var score_label = %ScoreLabel
@onready var timer_label = %TimerLabel  # Affichage du temps restant
@onready var restart_button: Button = %RestartButton
@onready var exit_button: Button = %ExitButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var current_question_index: int = 0
var score: int = 0
var audio_player: AudioStreamPlayer
var current_answers: Array[String] = []
var question_timer: Timer  # Le timer
var player :CharacterBody3D = null
var ui : Control = null

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	player = get_tree().get_first_node_in_group("Player")
	ui = get_tree().get_first_node_in_group("UI")
	
		# Créer et configurer le timer
	setup_timer()
	questions.shuffle()
	score_panel.hide()
	audio_button.pressed.connect(_on_audio_button_pressed)
	
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(_on_option_selected.bind(i))
	
	# Connecter le signal de visibilité pour réinitialiser le quiz
	visibility_changed.connect(_on_visibility_changed)
	
	#if questions.size() > 0:
		#push_error("Aucune question n'a été ajoutée!")

func setup_timer():
	# Créer le timer
	question_timer = Timer.new()
	add_child(question_timer)
	
	# Configurer le timer
	question_timer.wait_time = time_per_question
	question_timer.one_shot = true  # Ne se répète pas automatiquement
	
	# Connecter le signal timeout (se déclenche quand le timer atteint 0)
	question_timer.timeout.connect(_on_question_timeout)

func load_question(index: int):
	if index >= questions.size():
		show_score()
		return
	
	var question = questions[index]
	question_label.text = question.question_text
	
	# Charger l'audio si disponible
	if question.audio_stream:
		audio_player.stream = question.audio_stream
		audio_button.disabled = false
	else:
		audio_button.disabled = true
	
	# Mélanger et afficher les réponses
	current_answers = question.get_all_answers()
	for i in range(option_buttons.size()):
		if i < current_answers.size():
			option_buttons[i].text = current_answers[i]
			option_buttons[i].disabled = false
			option_buttons[i].show()
			option_buttons[i].release_focus()
		else:
			option_buttons[i].hide()
	
	# Démarrer le timer pour cette question
	question_timer.start()
	# Réinitialiser l'affichage du timer
	timer_label.text = "Temps: %.1f s" % time_per_question
	

# Cette fonction est appelée à chaque frame
func _process(_delta):
	if question_timer.time_left > 0:
		# Afficher le temps restant (arrondi à 1 décimale)
		timer_label.text = "Temps: %.1f s" % question_timer.time_left

func _on_audio_button_pressed():
	if audio_player.stream:
		audio_player.play()

func _on_option_selected(option_index: int):
	# Arrêter le timer car le joueur a répondu
	question_timer.stop()
	# Défocaliser le bouton cliqué
	option_buttons[option_index].release_focus()
	
	var selected_answer = current_answers[option_index]
	var correct_answer = questions[current_question_index].correct_answer
	
	if selected_answer == correct_answer:
		audio_stream_player.stream = CORRECTSOUND
		audio_stream_player.play()
		score += 1
		option_buttons[option_index].modulate = Color.GREEN
	else:
		audio_stream_player.stream = INCORRECTSOUND
		audio_stream_player.play()
		option_buttons[option_index].modulate = Color.RED
		# Montrer la bonne réponse en vert
		for i in range(current_answers.size()):
			if current_answers[i] == correct_answer:
				option_buttons[i].modulate = Color.GREEN
				break
	# Désactiver tous les boutons
	for btn in option_buttons:
		btn.disabled = true
	
	# Passer à la question suivante après un délai
	await get_tree().create_timer(1.2).timeout
	
	# Réinitialiser les couleurs
	for btn in option_buttons:
		btn.modulate = Color.WHITE
	
	current_question_index += 1
	load_question(current_question_index)

# Cette fonction est appelée quand le timer atteint 0
func _on_question_timeout():
	#print("Temps écoulé!")
	
	# Marquer toutes les réponses comme désactivées
	for btn in option_buttons:
		btn.disabled = true
		btn.modulate = Color.GRAY
	
	# Montrer la bonne réponse
	var correct_answer = questions[current_question_index].correct_answer
	for i in range(current_answers.size()):
		if current_answers[i] == correct_answer:
			option_buttons[i].modulate = Color.GREEN
	
	# Passer à la question suivante après un délai
	await get_tree().create_timer(2.0).timeout
	
	# Réinitialiser les couleurs
	for btn in option_buttons:
		btn.modulate = Color.WHITE
	
	current_question_index += 1
	load_question(current_question_index)

func show_score():
	question_timer.stop()  # Arrêter le timer
	
	# Cacher les éléments du quiz
	question_label.get_parent().hide()
	audio_button.hide()
	timer_label.hide()
	for btn in option_buttons:
		btn.hide()
	
	# Afficher le score
	score_panel.show()
	var total = questions.size()
	var percentage = (float(score) / float(total)) * 100
	score_label.text = "Score: %d / %d\n(%.1f%%)" % [score, total, percentage]
	if percentage < 70:
		exit_button.hide()
	

func restart_quiz():
	exit_button.show()
	# Réinitialiser les variables
	current_question_index = 0
	score = 0
	
	# Arrêter le timer et l'audio
	question_timer.stop()
	audio_player.stop()
	
	score_panel.hide()
	
	# Réafficher les éléments du quiz
	question_label.get_parent().show()
	audio_button.show()
	timer_label.show()
	for btn in option_buttons:
		btn.show()
		btn.modulate = Color.WHITE
		btn.disabled = false
	
	# Remélanger les questions pour une nouvelle partie
	questions.shuffle()
	
	# Charger la première question (le timer sera démarré dans load_question)
	load_question(0)

func _on_restart_button_pressed() -> void:
	restart_quiz()


func _on_exit_button_pressed() -> void:
	Global.emit_open_door_gate(door_nbr)
	game_over.emit()
	if player:
		player.can_move = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if ui:
		ui.show()
	
	# Réinitialiser complètement le quiz pour la prochaine fois
	current_question_index = 0
	score = 0
	question_timer.stop()
	audio_player.stop()
	score_panel.hide()
	
	# Remettre les éléments dans leur état initial
	question_label.get_parent().show()
	audio_button.show()
	timer_label.show()
	timer_label.text = "Temps: %.1f s" % time_per_question
	exit_button.show()
	
	for btn in option_buttons:
		btn.show()
		btn.modulate = Color.WHITE
		btn.disabled = false
	
	# Remélanger les questions
	questions.shuffle()
	
	hide()

func _on_visibility_changed() -> void:
	# Quand le quiz devient visible, on le réinitialise complètement
	if visible:
		current_question_index = 0
		score = 0
		question_timer.stop()
		audio_player.stop()
		score_panel.hide()
		if ui:
			ui.hide()
		
		# S'assurer que tous les éléments sont visibles
		question_label.get_parent().show()
		audio_button.show()
		timer_label.show()
		exit_button.show()
		ui = get_tree().get_first_node_in_group("UI")
		if ui:
			ui.hide()
		
		for btn in option_buttons:
			btn.show()
			btn.modulate = Color.WHITE
			btn.disabled = false
		
		# Remélanger et charger la première question
		questions.shuffle()
		load_question(0)


func _on_exit_quizz_btn_pressed() -> void:
	if player:
		player.can_move = true
	if ui:
		ui.show()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
