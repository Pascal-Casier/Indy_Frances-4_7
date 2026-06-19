extends CanvasLayer

signal kill_parent
signal success
signal exit

@export var door_nbr: int = -1

@export var phrases_raw: Array[String] = [
	"Dis 'Je suis un héros' pour avoir la clé !",
	"Je,suis,un,héros",
	"le,courir,est",
	
	"Maintenant dis 'Le chat dort' !",
	"Le,chat,dort",
	"vite,mange,rouge"
]

@onready var dialogue_text = %DialogText
@onready var sentence_container = %SentenceContainer
@onready var word_grid = %WordGrid
@onready var validate_button = %ValidationButton
@onready var feedback_label = %FeedbackLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const CORRECT_2 = preload("res://assets/sounds/sfx/correct_sound.mp3")
const INCORRECT_2 = preload("res://assets/sounds/sfx/wrong_answer.mp3")

var phrases: Array = []
var current_phrase_index: int = 0
var selected_words: Array[String] = []
var word_buttons: Array[Button] = []

func _ready():
	layer = 2
	validate_button.connect("pressed", _on_validate_pressed)
	_parse_phrases()
	start_dialogue()

func _parse_phrases():
	phrases.clear()
	var i = 0
	while i + 2 < phrases_raw.size():
		var arr_sentence: Array[String] = []
		var arr_dists: Array[String] = []
		arr_sentence.assign(phrases_raw[i + 1].split(","))
		arr_dists.assign(phrases_raw[i + 2].split(","))
		
		phrases.append({
			"npc_text": phrases_raw[i],
			"correct_sentence": arr_sentence,
			"distractors": arr_dists
		})
		i += 3

func start_dialogue():
	current_phrase_index = 0
	_load_phrase(current_phrase_index)

func _load_phrase(index: int):
	if index >= phrases.size():
		return
	
	var phrase = phrases[index]
	selected_words.clear()
	
	dialogue_text.text = phrase["npc_text"]
	
	for child in sentence_container.get_children():
		child.queue_free()
	for child in word_grid.get_children():
		child.queue_free()
	word_buttons.clear()
	
	# Compter les occurrences dans la phrase correcte
	var word_counts: Dictionary = {}
	for word in phrase["correct_sentence"]:
		word_counts[word] = word_counts.get(word, 0) + 1
	
	# Construire la liste de mots avec le bon nombre d'exemplaires
	var all_words: Array[String] = []
	all_words.assign(phrase["distractors"])
	for word in word_counts:
		for i in word_counts[word]:
			all_words.append(word)
	#all_words.append_array(phrase["distractors"])
	all_words.shuffle()
	
	for word in all_words:
		var button = Button.new()
		button.text = word
		button.connect("pressed", _on_word_selected.bind(word))
		word_grid.add_child(button)
		word_buttons.append(button)
	
	feedback_label.text = ""

func _on_word_selected(word: String):
	selected_words.append(word)
	
	var label = Label.new()
	label.text = word + " "
	sentence_container.add_child(label)
	
	for button in word_buttons:
		if button.text == word and button.disabled == false:
			button.disabled = true
			break

func _on_validate_pressed():
	var phrase = phrases[current_phrase_index]
	
	if selected_words == phrase["correct_sentence"]:
		audio_stream_player.stream = CORRECT_2
		audio_stream_player.play()
		
		current_phrase_index += 1
		if current_phrase_index < phrases.size():
			feedback_label.text = "Bravo ! Phrase suivante..."
			await get_tree().create_timer(1.0).timeout
			_load_phrase(current_phrase_index)
		else:
			feedback_label.text = "Bravo ! Toutes les phrases sont correctes !"
			Global.emit_open_door_gate(door_nbr)
			await get_tree().create_timer(1.3).timeout
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			hide()
			kill_parent.emit()
			success.emit()
			get_tree().paused = false
	else:
		feedback_label.text = "Oups, essaie encore !"
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
		selected_words.clear()
		for child in sentence_container.get_children():
			child.queue_free()
		for button in word_buttons:
			button.disabled = false

func reset_dialogue():
	_parse_phrases()
	start_dialogue()

func _on_button_exit_pressed() -> void:
	#layer = -1
	reset_dialogue()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	get_tree().paused = false
	exit.emit()
