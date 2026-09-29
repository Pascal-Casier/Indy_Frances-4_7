extends Control

signal exit
@export var door_nb : int = -1
@export var current_exercise: TranslationExercise:
	set(value):
		current_exercise = value
		if is_node_ready():
			setup_exercise()

@onready var french_label: Label = %FranchLabel
@onready var answer_container: HFlowContainer = %AnswerContainer
@onready var pool_container: HFlowContainer = %PoolContainer
@onready var feedback_label: Label = %FeedbackLabel
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

const CORRECT_SOUND = preload("uid://born1mix6seh0")
const INCORRECT_2 = preload("uid://c5k6jemod63hg")
const CLICK = preload("uid://c5dh7yd3ejg5t")

func _ready() -> void:
	if current_exercise:
		setup_exercise()

func setup_exercise() -> void:
	# Nettoyage
	clear_container(answer_container)
	clear_container(pool_container)
	feedback_label.text = ""
	
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
	# Alterne le bouton entre le pool de sélection et la zone de réponse
	if btn.get_parent() == pool_container:
		pool_container.remove_child(btn)
		answer_container.add_child(btn)
	else:
		answer_container.remove_child(btn)
		pool_container.add_child(btn)

func _on_reset_button_pressed() -> void:
	# Replacer tous les boutons choisis dans le pool initial
	for child in answer_container.get_children():
		if child is Button:
			answer_container.remove_child(child)
			pool_container.add_child(child)
	feedback_label.text = ""

func _on_validate_button_pressed() -> void:
	var selected_words: Array[String] = []
	for child in answer_container.get_children():
		if child is Button:
			selected_words.append(child.text)
	
	if selected_words == current_exercise.correct_tokens:
		feedback_label.text = "Parfait ! Réponse correcte."
		feedback_label.modulate = Color.MIDNIGHT_BLUE
		audio_stream_player.stream = CORRECT_SOUND
		audio_stream_player.play()
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
