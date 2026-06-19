extends CanvasLayer

# Variables exportées pour configurer les paires de mots dans l'inspecteur
@export var word_pairs: Array[WordPair] = []

# Références aux nœuds de l'interface
@onready var portuguese_label = %PortugueseLabel
@onready var formed_word_label = %FormedWordLabel
@onready var feedback_label = %FeedbackLabel
@onready var grid_container = %GridContainer

# Variables de jeu
var current_pair: WordPair
var formed_word: String = ""
var letter_buttons: Array[Button] = []
var available_pairs: Array[WordPair] = []

func _ready():
	# Récupérer les boutons de lettres
	for i in range(1, 10):
		var button = get_node("Control/TextureRect/MarginContainer/VBoxContainer/GridContainer/LetterButton" + str(i))
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
		# Désactiver tous les boutons
		for button in letter_buttons:
			button.disabled = true
		return
	
	# Choisir une paire de mots aléatoire
	var pair_index = randi() % available_pairs.size()
	current_pair = available_pairs[pair_index]
	formed_word = ""
	
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
		# Lancer un nouveau tour après un délai
		get_tree().create_timer(1.0).timeout.connect(start_new_round)
	else:
		feedback_label.text = "Incorrect, réessayez !"
		# Réinitialiser après un délai
		get_tree().create_timer(1.0).timeout.connect(reset_round)

func reset_round():
	formed_word = ""
	formed_word_label.text = ""
	feedback_label.text = ""
	# Réactiver tous les boutons
	for button in letter_buttons:
		button.disabled = false
	# Relancer le même mot
	var letters = generate_letters(current_pair.french)
	for i in range(9):
		letter_buttons[i].text = letters[i]
		letter_buttons[i].disabled = false
