extends CanvasLayer

signal game_over
# Variables exportées pour configurer les paires de mots dans l'inspecteur
@export var word_pairs: Array[WordPair] = []
@export var door_nbr : int = -1
# Références aux nœuds de l'interface
@onready var portuguese_label = %PortugueseLabel
@onready var formed_word_label = %FormedWordLabel
@onready var feedback_label = %FeedbackLabel
@onready var grid_container = %GridContainer
@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer

# Variables de jeu
var current_pair: WordPair
var formed_word: String = ""
var letter_buttons: Array[Button] = []
var available_pairs: Array[WordPair] = []
var hint_count: int = 0  # Compteur pour suivre le nombre d'indices donnés
const MAX_HINTS: int = 5  # Nombre maximum d'indices (ajustable selon la longueur des mots)
const CORRECT_SOUND = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECT_SOUND = preload("res://assets/sounds/sfx/incorrect2.ogg")

func _ready():
	feedback_label.text = "..."
	# Récupérer les boutons de lettres
	for i in range(1, 10):
		var button = get_node("Control/ColorRect/MarginContainer/Panel/MarginContainer/VBoxContainer/GridContainer/LetterButton" + str(i))
		letter_buttons.append(button)
		button.pressed.connect(_on_letter_button_pressed.bind(button))
	
	# Initialiser la liste des paires disponibles
	available_pairs = word_pairs.duplicate()
	
	# Charger un mot initial
	if available_pairs.size() > 0:
		start_new_round()
	else:
		feedback_label.text = "Aucune paire de mots configurée !"

func start_new_round():
	# Vérifier s'il reste des paires de mots
	if available_pairs.size() == 0:
		feedback_label.text = "Jeu terminé ! Plus de mots disponibles."
		game_finished()
		Global.emit_open_door_gate(door_nbr)
		# Désactiver tous les boutons
		for button in letter_buttons:
			button.disabled = true
		return
	else:
		feedback_label.text = "..."
	
	# Choisir une paire de mots aléatoire
	var pair_index = randi() % available_pairs.size()
	current_pair = available_pairs[pair_index]
	formed_word = ""
	hint_count = 0  # Réinitialiser le compteur d'indices
	
	# Mettre à jour les labels
	portuguese_label.text = current_pair.portuguese
	formed_word_label.text = ""
	feedback_label.text = ""
	
	# Générer les lettres pour la grille
	var letters = generate_letters(current_pair.french)
	
	# Réactiver et assigner les lettres aux boutons
	for i in range(9):
		letter_buttons[i].text = letters[i]
		letter_buttons[i].disabled = false
	
	# Retirer la paire utilisée
	available_pairs.remove_at(pair_index)

func generate_letters(target_word: String) -> Array:
	var letters: Array = []
	# Ajouter toutes les lettres du mot cible
	for letter in target_word.to_upper():
		letters.append(letter)
	
	# Compléter avec des lettres aléatoires jusqu'à 9
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	while letters.size() < 9:
		letters.append(alphabet[randi() % alphabet.length()])
	
	# Mélanger les lettres
	letters.shuffle()
	return letters

func _on_letter_button_pressed(button: Button):
	# Ajouter la lettre au mot formé
	formed_word += button.text
	formed_word_label.text = formed_word
	button.disabled = true
	
	# Vérifier si le mot formé correspond au mot cible
	if formed_word.length() == current_pair.french.length():
		check_word()

func check_word():
	if formed_word.to_lower() == current_pair.french.to_lower():
		feedback_label.text = "Correct !"
		audio_stream_player.stream = CORRECT_SOUND
		audio_stream_player.play()
		# Lancer un nouveau tour après un délai
		get_tree().create_timer(1.0).timeout.connect(start_new_round)
	else:
		audio_stream_player.stream = INCORRECT_SOUND
		audio_stream_player.play()
		feedback_label.text = "Incorrect, réessayez !"
		# Lancer l'effet de shake sur la barre d'indice
		shake_feedback_bar()
		# Donner un indice si le nombre maximum d'indices n'est pas atteint
		if hint_count < min(MAX_HINTS, current_pair.french.length()):
			give_hint()
		# Réinitialiser après un délai
		get_tree().create_timer(1.0).timeout.connect(reset_round)

func shake_feedback_bar():
	# Stocker la position initiale de la barre d'indice
	var original_position = feedback_label.position
	
	# Créer un Tween pour l'animation
	var tween = create_tween()
	
	# Paramètres de l'effet de shake
	var shake_strength = 10  # Distance maximale du déplacement (en pixels)
	var shake_duration = 0.05  # Durée de chaque mouvement (en secondes)
	var shake_cycles = 3  # Nombre de cycles de shake (aller-retour)
	
	# Animer le shake : déplacer la barre à gauche et à droite plusieurs fois
	for i in range(shake_cycles):
		# Déplacer à droite
		tween.tween_property(feedback_label, "position", original_position + Vector2(shake_strength, 0), shake_duration)
		# Déplacer à gauche
		tween.tween_property(feedback_label, "position", original_position + Vector2(-shake_strength, 0), shake_duration)
	
	# Remettre à la position initiale à la fin
	tween.tween_property(feedback_label, "position", original_position, shake_duration)

func give_hint():
	hint_count += 1
	# Construire l'indice en affichant toutes les lettres jusqu'à hint_count
	var hint_text = "Indice : les " + str(hint_count) + " premières lettres sont "
	var target_letters = current_pair.french.to_upper()
	for i in range(hint_count):
		hint_text += target_letters[i]
		if i < hint_count - 1:
			hint_text += " "
	feedback_label.text += " " + hint_text
	
	# Mettre en évidence le bouton avec la dernière lettre de l'indice
	var hint_index = hint_count - 1  # Indice de la dernière lettre à mettre en évidence
	var target_letter = target_letters[hint_index]
	for button in letter_buttons:
		if button.text == target_letter and button.disabled == false:
			# Mettre en évidence le bouton (jaune, par exemple)
			button.modulate = Color(1, 1, 0)  # Jaune pour mettre en évidence
			break

func reset_round():
	formed_word = ""
	formed_word_label.text = ""
	# Réinitialiser l'apparence des boutons
	for button in letter_buttons:
		button.modulate = Color(1, 1, 1)  # Remettre la couleur par défaut
		button.disabled = false
	# Relancer le même mot
	var letters = generate_letters(current_pair.french)
	for i in range(9):
		letter_buttons[i].text = letters[i]
		letter_buttons[i].disabled = false

func game_finished() -> void:
	%ButtonExit.text = "Sortie"
	
func _on_button_exit_pressed() -> void:
	hide()
	game_over.emit()
