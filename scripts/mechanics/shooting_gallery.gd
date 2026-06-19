extends Node3D

# Variables du jeu
var score: int = 0
@export var target_score: int = 5  # Objectif à atteindre
var current_portuguese_word: String = ""
var current_french_answer: String = ""
const victory_sound = preload("res://assets/sounds/musics/Victory.ogg")

@export var door_nbr := -1# Dictionnaire portugais-français
@export var word_pairs : Dictionary [String, String]= {
	"casa": "maison",
	"água": "eau",
	"livro": "livre",
	"gato": "chat",
	"carro": "voiture",
	"sol": "soleil",
	"lua": "lune",
	"árvore": "arbre",
	"flor": "fleur",
	"comida": "nourriture",
	"escola": "école",
	"amigo": "ami",
	"família": "famille",
	"trabalho": "travail",
	"tempo": "temps"
}

# Références aux objets de la scène
@onready var score_label = %ScoreLbl
@onready var portuguese_label = %PortuguesWordLabel
@onready var target_spawner = %TargetSpawner
@onready var game_over_panel = %GameOverPanel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var correct_sounds := [preload("res://assets/sounds/dialogues/bienjoue.mp3"),
						preload("res://assets/sounds/dialogues/bravo.mp3"),
						preload("res://assets/sounds/dialogues/cestcorrect.mp3")]
var incorrect_sounds := [preload("res://assets/sounds/dialogues/cestpascorrect.mp3"),
						preload("res://assets/sounds/dialogues/essaieencore.mp3"),
						preload("res://assets/sounds/dialogues/nonnon.mp3")]

signal word_hit(correct: bool)
signal game_finished(final_score: int)

func _ready():
	randomize()
	#update_ui()
	#spawn_new_round()

func start() -> void:
	update_ui()
	spawn_new_round()
	
func update_ui():
	score_label.text = "Score: " + str(score) + "/" + str(target_score)
	portuguese_label.text = current_portuguese_word

func spawn_new_round():
	# Choisir un mot portugais aléatoire
	var portuguese_words = word_pairs.keys()
	current_portuguese_word = portuguese_words[randi() % portuguese_words.size()]
	current_french_answer = word_pairs[current_portuguese_word]
	
	# Créer une liste de mots français incluant la bonne réponse
	var french_options = []
	french_options.append(current_french_answer)
	
	# Ajouter des mots français aléatoires (mauvaises réponses)
	var all_french_words = word_pairs.values()
	while french_options.size() < 4:  # 4 cibles au total
		var random_word = all_french_words[randi() % all_french_words.size()]
		if not french_options.has(random_word):
			french_options.append(random_word)
	
	# Mélanger les options
	french_options.shuffle()
	
	# Faire apparaître les cibles
	target_spawner.spawn_targets(french_options)
	update_ui()
	

func on_target_hit(french_word: String):
	var correct = (french_word == current_french_answer)
	
	if correct:
		var random_sound = correct_sounds[randi() % correct_sounds.size()]
		audio_stream_player.stream = random_sound
		audio_stream_player.play()
		score += 1
	else:
		var random_sound = incorrect_sounds[randi() % correct_sounds.size()]
		audio_stream_player.stream = random_sound
		audio_stream_player.play()
		if score > 0:
			score -= 1
	
	word_hit.emit(correct)
	
	if score >= target_score:
		update_ui()
		game_finished.emit(score)
		show_victory()
	else:
		# Attendre un moment puis nouvelle manche
		await get_tree().create_timer(1.0).timeout
		spawn_new_round()

func show_victory():
	#game_over_panel.show()
	score_label.text = "Score final: " + str(score)
	target_spawner.queue_free()
	audio_stream_player.stream = victory_sound
	audio_stream_player.play()
	%Area3DPressE.monitoring = false
	#await audio_stream_player.finished
	Global.emit_open_door_gate(door_nbr)

func _on_area_3d_press_e_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%pressE.show()

func _on_area_3d_press_e_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%pressE.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and %pressE.visible:
		start()
		%AudioStreamPlayerClic.play()
