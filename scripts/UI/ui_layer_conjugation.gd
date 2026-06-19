extends CanvasLayer

signal right_answer(is_correct: bool)

# Export des questions
@export var questions: Array[ConjugationQuestion] = []
@export var time_between_choices : float = 3.0

# Références UI
@onready var verbe_label = %LabelVerb
@onready var temps_label = %LabelTemp
@onready var personne_label = %LabelPerson
@onready var button1 = %BtnResp1
@onready var button2 = %BtnResp2
@onready var button3 = %BtnResp3
@onready var label_response: Label = %LabelResponse
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Variables internes
var current_question_index: int = 0
var current_correct_button: Button
var buttons: Array[Button] = []
var current_question: ConjugationQuestion
var is_showing : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Timer.wait_time = time_between_choices
	# Initialiser les boutons
	buttons = [button1, button2, button3]
	
	# Connecter les signaux
	button1.pressed.connect(_on_answer_button_pressed.bind(button1))
	button2.pressed.connect(_on_answer_button_pressed.bind(button2))
	button3.pressed.connect(_on_answer_button_pressed.bind(button3))
	
	# Charger la première question
	if questions.size() > 0:
		load_question(0)
	else:
		push_error("Aucune question n'a été ajoutée!")

func load_question(index: int):
	if questions.is_empty():
		return
	
	# Boucler sur les questions
	current_question_index = index % questions.size()
	current_question = questions[current_question_index]
	
	# Afficher les informations
	verbe_label.text = current_question.verbe
	temps_label.text = current_question.temps
	personne_label.text = current_question.personne
	
	# Créer un tableau avec toutes les réponses
	var answers = [
		current_question.correct_answer,
		current_question.wrong_answer_1,
		current_question.wrong_answer_2
	]
	
	# Mélanger les réponses
	answers.shuffle()
	
	# Assigner les réponses aux boutons
	for i in range(3):
		buttons[i].text = answers[i]
		
		# Mémoriser quel bouton a la bonne réponse
		if answers[i] == current_question.correct_answer:
			current_correct_button = buttons[i]
	
	# Réactiver tous les boutons
	for button in buttons:
		button.disabled = false

func _on_answer_button_pressed(button: Button):
	var is_correct = (button == current_correct_button)
	
	# Émettre le signal
	right_answer.emit(is_correct)
	
	if is_correct and label_response:
		# Formater : "Personne + verbe conjugué"
		var response_text = current_question.personne + " " + current_question.correct_answer
		label_response.text = response_text
	# Feedback visuel (optionnel)
	if is_correct:
		button.modulate = Color.GREEN
	else:
		button.modulate = Color.RED
		current_correct_button.modulate = Color.GREEN
	
	# Désactiver les boutons temporairement
	for btn in buttons:
		btn.disabled = true
	
	# Attendre un peu avant de charger la question suivante
	await get_tree().create_timer(1.5).timeout
	label_response.text = ""
	
	# Réinitialiser les couleurs
	for btn in buttons:
		btn.modulate = Color.WHITE
		btn.focus_mode = Control.FOCUS_NONE
	animation_player.play_backwards("show_game")
	is_showing = false
	$Timer.start()
	# Charger la question suivante
	load_question(current_question_index + 1)


func _on_timer_timeout() -> void:
	if !is_showing:
		$Timer.stop()
		animation_player.play("show_game")
		is_showing = true
	
		
