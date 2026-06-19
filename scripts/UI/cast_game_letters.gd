extends Control

signal end
signal exited
# Références aux nodes
@onready var word_display = %LabelMotPT
@onready var answer_display = %LabelReponse
@onready var letter_grid = %GrilleLettres
@onready var next_button = %Button
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var audio_stream_player_clic: AudioStreamPlayer = $AudioStreamPlayerClic


# Mots exportés pour l'inspecteur
@export var door_nb : int = -1
@export var portuguese_words: Array[String] = ["GATO", "CACHORRO", "CASA", "SOL", "ÁGUA", "LIVRO", "AMOR", "AMIGO", "FLOR", "NOITE"]
@export var french_words: Array[String] = ["CHAT", "CHIEN", "MAISON", "SOLEIL", "EAU", "LIVRE", "AMOUR", "AMI", "FLEUR", "NUIT"]
@export var shuffle_words: bool = true
@export var extra_random_letters: Array[String] = ["A", "E", "I", "O", "U", "R", "S", "T", "N", "L", "P", "M", "D", "C", "B"]


# Données du jeu
var word_pairs = []
var current_word_index = 0
var current_answer = ""
var correct_word = ""
var letter_buttons = []

func _ready():
	randomize()
	_initialize_game()

func _initialize_game():
	# Construire word_pairs à partir des tableaux exportés
	word_pairs.clear()
	var min_length = min(portuguese_words.size(), french_words.size())
	for i in range(min_length):
		word_pairs.append({"pt": portuguese_words[i], "fr": french_words[i]})
	
	if shuffle_words:
		word_pairs.shuffle()
	
	# Activer BBCode sur le RichTextLabel
	if answer_display is RichTextLabel:
		answer_display.bbcode_enabled = true
	
	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)
	
	next_button.text = "Mot suivant"
	next_button.visible = false
	
	# Réinitialiser l'index
	current_word_index = 0
	
	# Charger le premier mot
	load_new_word()

func _restart():
	# Réinitialiser les variables
	current_word_index = 0
	current_answer = ""
	correct_word = ""
	letter_buttons.clear()
	
	# Nettoyer la grille
	for child in letter_grid.get_children():
		child.queue_free()
	
	# NE PAS rappeler _initialize_game() ici
	# Juste préparer pour le prochain load_new_word()


func load_new_word():
	# Vérifier que word_pairs n'est pas vide et que l'index est valide
	if word_pairs.is_empty() or current_word_index >= word_pairs.size():
		push_error("word_pairs est vide ou index invalide")
		return
	
	# Réinitialiser
	show()
	current_answer = ""
	letter_buttons.clear()
	
	# Nettoyer la grille
	for child in letter_grid.get_children():
		child.queue_free()
	
	# Obtenir le mot actuel
	var word_data = word_pairs[current_word_index]
	var portuguese_word = word_data["pt"]
	correct_word = word_data["fr"]
	
	# Afficher le mot en portugais
	word_display.text = "Traduisez en français: " + portuguese_word
	update_answer_display()
	
	# Créer les lettres pour la grille
	var letters = []
	for letter in correct_word:
		letters.append(letter)
	
	# Ajouter des lettres aléatoires supplémentaires pour atteindre 9
	while letters.size() < 9:
		var random_letter = extra_random_letters[randi() % extra_random_letters.size()]
		if letters.count(random_letter) < correct_word.count(random_letter) + 2:
			letters.append(random_letter)
	
	# Mélanger les lettres
	letters.shuffle()
	
	# Créer les boutons
	for i in range(9):
		var button = Button.new()
		button.text = letters[i]
		button.custom_minimum_size = Vector2(80, 80)
		button.add_theme_font_size_override("font_size", 32)
		button.pressed.connect(_on_letter_pressed.bind(button, letters[i]))
		letter_grid.add_child(button)
		letter_buttons.append(button)
	
	next_button.visible = false

func _on_letter_pressed(button: Button, letter: String):
	audio_stream_player_clic.play()
	# Ajouter la lettre à la réponse
	current_answer += letter
	button.disabled = true
	
	# Mettre à jour l'affichage
	update_answer_display()
	
	# Vérifier si la réponse est complète
	if current_answer.length() == correct_word.length():
		check_answer()

func update_answer_display():
	var display = ""
	
	# Construire le texte avec les couleurs BBCode
	for i in range(correct_word.length()):
		if i < current_answer.length():
			# Comparer la lettre actuelle avec la lettre correcte
			if current_answer[i] == correct_word[i]:
				display += "[color=green]" + current_answer[i] + "[/color]"
			else:
				display += "[color=red]" + current_answer[i] + "[/color]"
		else:
			display += "_"
	
	# Utiliser text pour RichTextLabel avec BBCode
	if answer_display is RichTextLabel:
		answer_display.text = display
	else:
		answer_display.text = display.replace("[color=green]", "").replace("[color=red]", "").replace("[/color]", "")

func check_answer():
	if current_answer == correct_word:
		audio_stream_player.play()
		Global.emit_open_door_gate(door_nb)
		var display = "[color=green]✓ " + current_answer + " - Correct![/color]"
		if answer_display is RichTextLabel:
			answer_display.text = display
		else:
			answer_display.text = "✓ " + current_answer + " - Correct!"
		next_button.visible = true
		
		# Désactiver tous les boutons
		for btn in letter_buttons:
			btn.disabled = true
	else:
		var display = "[color=red]✗ " + current_answer + " - Essayez encore![/color]"
		if answer_display is RichTextLabel:
			answer_display.text = display
		else:
			answer_display.text = "✗ " + current_answer + " - Essayez encore!"
		
		# Permettre de réessayer après un délai
		await get_tree().create_timer(1.5).timeout
		reset_current_word()

func reset_current_word():
	current_answer = ""
	
	# Réactiver tous les boutons
	for btn in letter_buttons:
		btn.disabled = false
	
	update_answer_display()

func _on_next_button_pressed():
	current_word_index += 1
	
	if current_word_index >= word_pairs.size():
		# Fin du jeu
		word_display.text = "Félicitations! Vous avez terminé!"
		answer_display.text = ""
		next_button.visible = false
		
		# Nettoyer la grille
		for child in letter_grid.get_children():
			child.queue_free()
		
		await get_tree().create_timer(1.8).timeout
		
		# Réinitialiser complètement le jeu
		current_word_index = 0
		_initialize_game()  # Seulement ici, une seule fois
		
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		end.emit()
	else:
		load_new_word()

func _on_button_exit_pressed() -> void:
	# Réinitialiser l'index avant de réinitialiser
	current_word_index = 0
	current_answer = ""
	correct_word = ""
	letter_buttons.clear()
	
	# Nettoyer la grille
	for child in letter_grid.get_children():
		child.queue_free()
	
	_initialize_game()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	exited.emit()
