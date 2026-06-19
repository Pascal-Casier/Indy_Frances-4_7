extends Node

# Configuration du jeu
@export var door_nbr : int = -1
@export var time_limit: float = 5.0  # Temps limite par lettre en secondes
@export var base_points: int = 100  # Points de base par lettre correcte
@export var penalty_on_error: int = 20  # Points perdus en cas d'erreur
@export var restart_on_error: bool = false  # Si true, recommence le mot à zéro sur erreur
@export var word_list: Array[String] = [
	"chat",
	"maison",
	"soleil",
	"livre",
	"jardin"
]  # Liste des mots à deviner
@export var translations_pt: Array[String] = [
	"gato",
	"casa",
	"sol",
	"livro",
	"jardim"
]  # Traductions en portugais (même ordre que word_list)

# Variables de jeu
var current_word: String = ""
var current_letter_index: int = 0
var score: int = 0
var timer: float = 0.0
var game_active: bool = false
var remaining_words: Array[String] = []  # Mots restants à deviner
var completed_words: Array[Dictionary] = []  # Mots complétés avec leurs traductions
var player : CharacterBody3D = null

# Références aux nodes (à configurer dans l'éditeur ou _ready)
@onready var letter_sounds: Dictionary = {}  # Dictionnaire lettre -> AudioStreamPlayer
@onready var ui_label: RichTextLabel  # Pour afficher le mot en cours
@onready var score_label: Label  # Pour afficher le score
@onready var timer_label: Label  # Pour afficher le temps restant
@onready var replay_button: Button  # Bouton pour réécouter le son
@onready var victory_panel: Control  # Panel de victoire
@onready var victory_label: Label  # Label pour le message de victoire
@onready var word_list_label: RichTextLabel  # Label pour la liste des mots traduits
@onready var traduction_label: Label = %TraductionLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var success_particles: GPUParticles2D = $SuccessParticles
@onready var audio_stream_player_success: AudioStreamPlayer = $AudioStreamPlayerSuccess
@onready var intro_panel: TextureRect = $Intro



func _ready():
	# Initialiser les références UI (ajustez selon votre scène)
	ui_label = get_node_or_null("WordLabel")
	score_label = get_node_or_null("ScoreLabel")
	timer_label = get_node_or_null("TimerLabel")
	replay_button = get_node_or_null("ReplayButton")
	victory_panel = get_node_or_null("VictoryPanel")
	victory_label = get_node_or_null("VictoryPanel/VictoryLabel")
	word_list_label = get_node_or_null("VictoryPanel/ScrollContainer/WordListLabel")
	
	player = get_tree().get_first_node_in_group("Player")
	# Cacher le panel de victoire au départ
	if victory_panel:
		victory_panel.visible = false
	
	# Connecter le signal du bouton replay
	if replay_button:
		replay_button.pressed.connect(_on_replay_button_pressed)
	
	# Charger les sons des lettres
	load_letter_sounds()
	
	# Initialiser la liste des mots restants
	initialize_word_list()
	
	# Démarrer le jeu
	#start_new_word()

func _process(delta):
	if not game_active:
		return
	
	# Décompte du timer
	timer -= delta
	
	if timer_label:
		timer_label.text = "Temps: %.1f" % max(0, timer)
	
	# Vérifier si le temps est écoulé
	if timer <= 0:
		on_time_expired()

func _input(event):
	if not game_active:
		return
	
	# Détecter la frappe de touche
	if event is InputEventKey and event.pressed and not event.echo:
		var key_pressed = OS.get_keycode_string(event.keycode).to_lower()
		check_letter_input(key_pressed)
		get_viewport().set_input_as_handled()

func load_letter_sounds():
	# Chargement des sons depuis res://assets/sounds/Alphabet2/
	var letters = "abcdefghijklmnopqrstuvwxyz"
	for letter in letters:
		var sound_path = "res://assets/sounds/Alphabet2/%s.mp3" % letter.to_upper()
		if ResourceLoader.exists(sound_path):
			var audio_player = AudioStreamPlayer.new()
			audio_player.stream = load(sound_path)
			add_child(audio_player)
			letter_sounds[letter] = audio_player
		else:
			print("Son manquant pour la lettre: ", letter)

func initialize_word_list():
	# Copier tous les mots dans remaining_words et les mélanger
	remaining_words = word_list.duplicate()
	remaining_words.shuffle()

func start_new_word():
	# Vérifier s'il reste des mots
	if remaining_words.is_empty():
		show_victory()
		return
	
	# Prendre le premier mot de la liste (déjà mélangée)
	current_word = remaining_words.pop_front()
	current_letter_index = 0
	game_active = true
	timer = time_limit
	
	# Afficher le mot masqué
	update_word_display()

	# Afficher la traduction
	update_translation_display()
	
	# Jouer le son de la première lettre
	play_current_letter_sound()
	
	#print("Nouveau mot: ", current_word, " (Restants: ", remaining_words.size(), ")")

func update_translation_display():
	if not traduction_label:
		return
	
	# Trouver l'index du mot actuel dans la liste originale
	var word_index = word_list.find(current_word)
	
	if word_index >= 0 and word_index < translations_pt.size():
		var translation = translations_pt[word_index]
		traduction_label.text = "(%s)" % translation
		traduction_label.visible = true
	else:
		traduction_label.visible = false

func check_letter_input(key: String):
	var expected_letter = current_word[current_letter_index]
	
	if key == expected_letter:
		on_correct_letter()
	else:
		on_wrong_letter()

func on_correct_letter():
	# Calculer les points en fonction du temps restant
	var time_bonus = int(timer / time_limit * base_points)
	var points_earned = base_points + time_bonus
	score += points_earned
	
	#print("Lettre correcte! +%d points" % points_earned)
	
	# Passer à la lettre suivante
	current_letter_index += 1
	
	# Mettre à jour l'affichage AVANT de vérifier si le mot est complet
	# pour afficher la dernière lettre en vert
	update_word_display()
	
	# Vérifier si le mot est complet
	if current_letter_index >= current_word.length():
		on_word_completed()
	else:
		# Réinitialiser le timer
		timer = time_limit
		
		# Jouer le son de la prochaine lettre
		play_current_letter_sound()
	
	# Mettre à jour le score
	update_score_display()
	var tween = create_tween()
	tween.tween_property(ui_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(ui_label, "scale", Vector2(1.0, 1.0), 0.1)

func on_wrong_letter():
	#print("Mauvaise lettre!")
	
	if restart_on_error:
		# Recommencer le mot à zéro
		current_letter_index = 0
		timer = time_limit
		update_word_display()
		play_current_letter_sound()
	else:
		# Perdre des points
		score = max(0, score - penalty_on_error)
		update_score_display()
		
		# Optionnel: jouer un son d'erreur
		play_error_sound()

func on_time_expired():
	print("Temps écoulé!")
	
	if restart_on_error:
		# Recommencer le mot
		current_letter_index = 0
		timer = time_limit
		update_word_display()
		play_current_letter_sound()
	else:
		# Perdre des points et continuer
		score = max(0, score - penalty_on_error)
		timer = time_limit
		update_score_display()

func on_word_completed():
	print("Mot complété! Score total: ", score)
	game_active = false
	
	# Bonus pour mot complet
	score += 200
	update_score_display()
	
	if success_particles:
		success_particles.restart()
		
	# Sauvegarder le mot complété avec sa traduction
	var word_index = word_list.find(current_word)
	var translation = ""
	if word_index >= 0 and word_index < translations_pt.size():
		translation = translations_pt[word_index]
	
	completed_words.append({
		"french": current_word,
		"portuguese": translation
	})
	
	# Jouer un son de victoire
	play_success_sound()
	
	# Attendre un peu puis passer au mot suivant
	await get_tree().create_timer(2.0).timeout
	start_new_word()

func play_current_letter_sound():
	var current_letter = current_word[current_letter_index]
	if letter_sounds.has(current_letter):
		letter_sounds[current_letter].play()
	else:
		print("Son manquant pour: ", current_letter)

func play_error_sound():
	audio_stream_player.play()
	pass

func play_success_sound():
	audio_stream_player_success.play()
	pass

func update_word_display():
	if not ui_label:
		return
	
	var display_text = ""
	for i in range(current_word.length()):
		if i < current_letter_index:
			# Lettres déjà trouvées (en vert par exemple)
			display_text += "[color=green]%s[/color]" % current_word[i]
		elif i == current_letter_index:
			# Lettre actuelle (en jaune)
			display_text += "[color=yellow]_[/color]"
		else:
			# Lettres à venir
			display_text += "_"
		display_text += " "
	
	ui_label.text = display_text

func update_score_display():
	if score_label:
		score_label.text = "Score: %d" % score

func _on_replay_button_pressed():
	# Rejouer le son de la lettre actuelle
	if game_active:
		play_current_letter_sound()

func show_victory():
	# Arrêter le jeu
	game_active = false
	
	# Afficher le panel de victoire
	if victory_panel:
		victory_panel.visible = true
	
	# Afficher le message avec le score final
	if victory_label:
		victory_label.text = "🎉 FÉLICITATIONS ! 🎉\n\nVous avez terminé tous les mots !\nScore final : %d points" % score
	
	# Afficher la liste des mots avec traductions
	if word_list_label:
		var list_text = "[center][b]Mots appris :[/b][/center]\n\n"
		for word_data in completed_words:
			list_text += "[color=green]%s[/color] → [color=yellow]%s[/color]\n" % [word_data["french"], word_data["portuguese"]]
		word_list_label.text = list_text
	
	print("Victoire ! Score final : ", score)


func _on_button_exit_pressed() -> void:
	victory_panel.hide()
	start_new_word()
	Global.emit_open_door_gate(door_nbr)
	if player:
		player.can_move = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$".".hide()

func _on_button_recommencer_pressed() -> void:
		# Réinitialiser le score
	score = 0
	update_score_display()
	
	# Vider les mots complétés
	completed_words.clear()
	
	# Réinitialiser la liste des mots (re-mélanger)
	initialize_word_list()
	
	# Réinitialiser l'index de lettre
	current_letter_index = 0
	
	# Cacher le panel de victoire
	if victory_panel:
		victory_panel.visible = false
	
	# Remettre le timer à zéro
	timer = time_limit
	
	# Démarrer le premier mot
	start_new_word()
	


func _on_button_start_pressed() -> void:
	intro_panel.hide()
	start_new_word()


	
