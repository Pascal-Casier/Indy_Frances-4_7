extends Control

signal exit
# Utilisez une variable exportée pour charger la ressource.
# Vous pourrez glisser-déposer votre fichier .tres ici directement depuis l'éditeur.
@export var door_nbr : int = -1
@export var vocabulary_data: VocabularyData

# Variable pour stocker la scène de la carte préfabriquée
@onready var card_scene = preload("res://scenes/UI/MemoryVocabGame/memoryCard.tscn")

# Nœuds de l'interface utilisateur
@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel
@onready var game_board: GridContainer = %GameBoard
@onready var restart_button: Button = %RestartButton
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var texture_rect: TextureRect = %TextureRect
const CORRECT_2 = preload("res://assets/sounds/sfx/correct_sound.mp3")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect_sound.mp3")

var selected_cards: Array[Button] = []
var matched_pairs: int = 0
var total_pairs: int = 0
var is_processing_turn: bool = false

# --- Variables pour le système de score ---
var start_time: float = 0.0
var incorrect_attempts: int = 0

func _ready():
	start_game()

func start_game():
	# Assurer que la ressource de vocabulaire a été chargée
	if not vocabulary_data:
		print_debug("Erreur: La ressource VocabularyData n'est pas chargée!")
		message_label.text = "Erreur: Vocabulaire manquant."
		return
	# Initialiser le jeu en fonction du vocabulaire chargé
	total_pairs = vocabulary_data.pairs.size()
	message_label.text = "Associez les mots !"
	restart_button.hide()
	matched_pairs = 0
	is_processing_turn = false
	
	# Réinitialiser les variables de score au début de la partie
	incorrect_attempts = 0
	start_time = Time.get_ticks_msec() # Commence le chronomètre

	# Nettoyer le plateau de jeu
	for child in game_board.get_children():
		child.queue_free()
	
	create_board()

func create_board():
	# Créer une liste de mots/paires à partir de la ressource
	var all_words: Array = []
	for key in vocabulary_data.pairs:
		all_words.append({"word": key, "match": vocabulary_data.pairs[key]})
		all_words.append({"word": vocabulary_data.pairs[key], "match": key})

	all_words.shuffle()

	# Remplir la grille avec les cartes
	for pair in all_words:
		var new_card = card_scene.instantiate()
		game_board.add_child(new_card)
		new_card.word = pair.word
		new_card.match = pair.match
		new_card.text = pair.word
		new_card.pressed.connect(_on_card_pressed.bind(new_card))

func _on_card_pressed(card: Button):
	# Si la carte est déjà sélectionnée, appariée, ou que le jeu est en cours de traitement, ignorer le clic
	if is_processing_turn or card.modulate == Color.DEEP_SKY_BLUE or card.modulate == Color.SEA_GREEN:
		return
	
	card.modulate = Color.DEEP_SKY_BLUE # Marquer comme sélectionné
	selected_cards.append(card)

	if selected_cards.size() == 2:
		is_processing_turn = true # Bloquer les clics
		var card1 = selected_cards[0]
		var card2 = selected_cards[1]
		
		# Empêcher d'appuyer sur la même carte deux fois
		if card1 == card2:
			card1.modulate = Color.WHITE
			is_processing_turn = false
			selected_cards.clear()
			return

		if card1.match == card2.text:
			# C'est une paire
			message_label.text = "Bien joué !"
			card1.modulate = Color.SEA_GREEN
			card2.modulate = Color.SEA_GREEN
			audio_stream_player.stream = CORRECT_2
			audio_stream_player.play()
			
			matched_pairs += 1
			
			if matched_pairs == total_pairs:
				_on_game_finished()
		else:
			# Mauvaise paire
			message_label.text = "Non, ce n'est pas la bonne paire."
			
			# Incrémenter le compteur d'erreurs
			incorrect_attempts += 1
			
			card1.modulate = Color.INDIAN_RED
			card2.modulate = Color.INDIAN_RED
			audio_stream_player.stream = INCORRECT_2
			audio_stream_player.play()
			
			# Réinitialiser après un court délai
			await get_tree().create_timer(1.0).timeout
			card1.modulate = Color.WHITE
			card2.modulate = Color.WHITE

		selected_cards.clear()
		is_processing_turn = false # Débloquer les clics

func _on_game_finished():
	var end_time = Time.get_ticks_msec()
	var time_elapsed = (end_time - start_time) / 1000.0

	# Calculer le score : bonnes réponses / total des tentatives
	var total_attempts = total_pairs + incorrect_attempts
	var score_percent = (float(total_pairs) / float(total_attempts)) * 100.0

	if score_percent >= 70.0:
		message_label.text = "Bravo ! Score : %.0f%% en %.2f secondes." % [score_percent, time_elapsed]
		restart_button.show()
	else:
		message_label.text = "Score : %.0f%% — Il faut 70%% pour continuer. Réessayez !" % [score_percent]
		restart_button.hide()
	

func _on_restart_button_pressed():
	exit.emit()
	Global.emit_open_door_gate(door_nbr)
	hide()
	#start_game()


func _on_reset_pressed() -> void:
	start_game()
