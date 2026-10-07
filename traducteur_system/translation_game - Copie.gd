extends Control

signal exit
@export var door_nb : int = -1

## Remplace la variable unique par une liste d'exercices
@export var exercises: Array[TranslationExercise] = []

## Indice de l'exercice actuel
var current_exercise_index: int = 0

## Propriété calculée pour obtenir l'exercice en cours
var current_exercise: TranslationExercise:
	get:
		if current_exercise_index >= 0 and current_exercise_index < exercises.size():
			return exercises[current_exercise_index]
		return null

@onready var french_label: Label = %FranchLabel
@onready var answer_container: HFlowContainer = %AnswerContainer
@onready var pool_container: HFlowContainer = %PoolContainer
@onready var feedback_label: Label = %FeedbackLabel
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

const CORRECT_SOUND = preload("uid://born1mix6seh0")
const INCORRECT_2 = preload("uid://c5k6jemod63hg")
const CLICK = preload("uid://c5dh7yd3ejg5t")

func _ready() -> void:
	start_exercises()

## Démarrer la série d'exercices depuis le début
func start_exercises() -> void:
	current_exercise_index = 0
	%ButtonExit.hide()
	if exercises.size() > 0:
		setup_exercise()

func setup_exercise() -> void:
	# Nettoyage
	clear_container(answer_container)
	clear_container(pool_container)
	feedback_label.text = ""
	
	if not current_exercise:
		return
	
	french_label.text = current_exercise.french_sentence
	
	# Fusion de la bonne réponse et des intrus
	var all_words: Array[String] = []
	all_words.append_array(current_exercise.correct_tokens)
	all_words.append_array(current_exercise.distractor_tokens)
	
	# Mélange aléatoire des mots
	all_words.shuffle()
	
	# Création des boutons de mots dans le PoolContainer
	for word in all_words:
		var btn = Button.new()
		btn.text = word
		btn.pressed.connect(_on_word_button_pressed.bind(btn))
		pool_container.add_child(btn)

func _on_word_button_pressed(btn: Button) -> void:
	if btn.get_parent() == pool_container:
		pool_container.remove_child(btn)
		answer_container.add_child(btn)
	else:
		answer_container.remove_child(btn)
		pool_container.add_child(btn)

func _on_reset_button_pressed() -> void:
	for child in answer_container.get_children():
		if child is Button:
			answer_container.remove_child(child)
			pool_container.add_child(child)
	feedback_label.text = ""

func _on_validate_button_pressed() -> void:
	if not current_exercise:
		return

	var selected_words: Array[String] = []
	for child in answer_container.get_children():
		if child is Button:
			selected_words.append(child.text)
	
	if selected_words == current_exercise.correct_tokens:
		feedback_label.text = "Parfait ! Réponse correcte."
		feedback_label.modulate = Color.MIDNIGHT_BLUE
		audio_stream_player.stream = CORRECT_SOUND
		audio_stream_player.play()
		
		# Attendre un court instant ou passer directement à la suite
		current_exercise_index += 1
		
		if current_exercise_index < exercises.size():
			# S'il reste des exercices, charger le suivant (après un petit délai optionnel)
			await get_tree().create_timer(1.0).timeout
			setup_exercise()
		else:
			# Tous les exercices sont réussis
			show_exit_btn()
	else:
		feedback_label.text = "Incorrect, réessayez !"
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
		feedback_label.modulate = Color.BROWN

func clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func show_exit_btn() -> void:
	%ButtonExit.show()

func _on_button_exit_pressed() -> void:
	audio_stream_player.stream = CLICK
	audio_stream_player.play()
	hide()
	Global.emit_open_door_gate(door_nb)
	exit.emit()
