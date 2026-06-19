class_name QuizPanel extends Control

signal exit

@export var title : String = "Quiz"
@export var resource_list : Array[ResourceWord]

@onready var grid_container: GridContainer = %GridContainer2
@onready var replay_button: Button = %ReplayButton
@onready var score_label: Label = %ScoreLabel
@onready var feedback_label: Label = %FeedbackLabel
@onready var dictionnary_panel: DictionnaryPanel = $".."
@onready var audio_stream_quizz: AudioStreamPlayer = %AudioStreamQuizz
const CORRECT = preload("res://assets/sounds/sfx/Coins 6 - Sound effects Pack 2.ogg")
const INCORRECT = preload("res://assets/sounds/sfx/incorrect2.ogg")

var buttons_list = []
var current_word_index : int = 0
var current_audio_player : AudioStreamPlayer
var score : int = 0
var total_questions : int = 0
var used_indices : Array[int] = []
var door_nbr : int = -1

func _ready() -> void:
	%Label.text = title
	current_audio_player = AudioStreamPlayer.new()
	add_child(current_audio_player)
	# Connecter le bouton replay
	replay_button.connect("pressed", Callable(self, "_on_replay_button_pressed"))
	#setup_quiz()

func setup_quiz() -> void:
	# Vérifier qu'on a bien une liste de ressources
	if resource_list.is_empty():
		feedback_label.text = "Aucun mot à tester !"
		return
	# Nettoyer les anciens boutons
	for button in buttons_list:
		button.queue_free()
	buttons_list.clear()
	# Nettoyer le bouton d'action (Recommencer/Sortir) s'il existe
	for child in grid_container.get_children():
		if child.text == "Recommencer" or child.text == "Sortir":
			child.queue_free()
	
	# Créer les boutons pour tous les mots
	for i in resource_list.size():
		var b = Button.new()
		if resource_list[i].photo:
			b.icon = resource_list[i].photo
			b.expand_icon = true
		else:
			# Fallback vers le texte si pas d'image
			b.text = resource_list[i].word
		
		# Connecter le signal avec l'index du mot
		b.connect("pressed", Callable(self, "_on_word_button_pressed").bind(i))
		
		# Style du bouton
		b.custom_minimum_size = Vector2(66, 66)
		
		grid_container.add_child(b)
		buttons_list.append(b)
	
	
	
	# Commencer le premier test
	next_question()

func next_question() -> void:
	# Vérifier si on a testé tous les mots
	if used_indices.size() >= resource_list.size():
		end_quiz()
		return
	
	# Choisir un mot aléatoire non encore utilisé
	var available_indices = []
	for i in resource_list.size():
		if i not in used_indices:
			available_indices.append(i)
	
	if available_indices.size() > 0:
		current_word_index = available_indices[randi() % available_indices.size()]
		used_indices.append(current_word_index)
		
		# Jouer le son du mot choisi
		if resource_list[current_word_index].sound:
			current_audio_player.stream = resource_list[current_word_index].sound
			current_audio_player.play()
		
		total_questions += 1
		feedback_label.text = "Quel mot correspond à ce son ?"
		
		# Réactiver tous les boutons
		for button in buttons_list:
			button.disabled = false
			button.modulate = Color.WHITE

func _on_word_button_pressed(selected_index: int) -> void:
	# Vérifier si c'est la bonne réponse
	if selected_index == current_word_index:
		# Bonne réponse
		audio_stream_quizz.stream = CORRECT
		audio_stream_quizz.play()
		score += 1
		feedback_label.text = "Bravo ! C'est correct !"
		buttons_list[selected_index].modulate = Color.GREEN
	else:
		# Mauvaise réponse
		audio_stream_quizz.stream = INCORRECT
		audio_stream_quizz.play()
		feedback_label.text = "Essaie encore ! La bonne réponse était : " + resource_list[current_word_index].word
		buttons_list[selected_index].modulate = Color.RED
		buttons_list[current_word_index].modulate = Color.GREEN
	
	# Mettre à jour le score
	update_score_display()
	
	# Désactiver tous les boutons temporairement
	for button in buttons_list:
		button.disabled = true
	
	# Attendre 2 secondes puis passer à la question suivante
	await get_tree().create_timer(2.0).timeout
	next_question()

func _on_replay_button_pressed() -> void:
	# Rejouer le son actuel
	if current_audio_player.stream:
		current_audio_player.play()

func update_score_display() -> void:
	score_label.text = "Score : " + str(score) + "/" + str(total_questions)

func end_quiz() -> void:
	var percentage = float(score) / float(total_questions) * 100.0
	var success_threshold = 70.0
	if percentage >= success_threshold:
		feedback_label.text = "Bravo ! Quiz réussi ! Score final : " + str(score) + "/" + str(total_questions) + " (" + str(int(percentage)) + "%)"
	else:
		feedback_label.text = "Score insuffisant : " + str(score) + "/" + str(total_questions) + " (" + str(int(percentage)) + "%). Il faut au moins " + str(int(success_threshold)) + "% pour réussir."
	
	# Désactiver tous les boutons
	for button in buttons_list:
		button.disabled = true
	# Ajouter le bouton approprié selon le résultat
	var action_button = Button.new()
	if percentage >= success_threshold:
		action_button.text = "Sortir"
		action_button.pressed.connect(exit_quiz)
		#action_button.connect("pressed", Callable(self, "exit_quiz"))
	else:
		action_button.text = "Recommencer"
		action_button.connect("pressed", Callable(self, "restart_quiz"))
		
	action_button.custom_minimum_size = Vector2(170, 66)
	grid_container.add_child(action_button)

func restart_quiz() -> void:
	score = 0
	total_questions = 0
	used_indices.clear()
	
	# Supprimer le bouton recommencer s'il existe
	for child in grid_container.get_children():
		if child.text == "Recommencer" or child.text == "Sortir":
			child.queue_free()
	
	setup_quiz()

func exit_quiz() -> void:
	# Retourner au dictionnaire ou fermer le quiz
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.emit_open_door_gate(door_nbr)
	dictionnary_panel.button_quizz.hide()
	hide()
	exit.emit()
	# Optionnel : afficher le dictionnaire parent si vous avez une référence
	# parent_dictionary.show()

func _on_button_exit_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
