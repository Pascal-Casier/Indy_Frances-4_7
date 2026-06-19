# ConjugaisonGame.gd
extends Control

signal game_over
signal exited
# Structure pour une question exportable
@export_group("Questions")
@export var phrases: Array[String] = []
@export var reponses_correctes: Array[String] = []
@export var verbes: Array[String] = []  # "être" ou "avoir"

@export_group("Conjugaisons")
@export var conjugaisons_etre: Array[String] = ["suis", "es", "est", "sommes", "êtes", "sont"]
@export var conjugaisons_avoir: Array[String] = ["ai", "as", "a", "avons", "avez", "ont"]

# Structure interne pour une question
class Question:
	var phrase: String = ""
	var reponse_correcte: String = ""
	var verbe: String = ""
	
	func _init(p_phrase: String = "", p_reponse: String = "", p_verbe: String = ""):
		phrase = p_phrase
		reponse_correcte = p_reponse
		verbe = p_verbe

# Variables de jeu
var questions: Array[Question] = []

# Références aux nœuds de l'interface
@onready var label_phrase = %PhraseLabel
@onready var container_boutons = %BoutonsContainer
@onready var label_score = %ScoreLabel
@onready var bouton_suivant = %BoutonSuivant
@onready var barre_progression: ProgressBar = %BarreProgression

# Variables de jeu
var question_actuelle: int = 0
var score: int = 0
var boutons_conjugaison: Array[Button] = []

func _ready():
	if barre_progression:
		barre_progression.min_value = 0
		barre_progression.max_value = 100
		barre_progression.value = 0
		barre_progression.show_percentage = false  # Optionnel
	# Charger les questions depuis les arrays exportés
	charger_questions_depuis_exports()
	
	# Si aucune question n'est définie, créer des exemples
	if questions.is_empty():
		creer_questions_defaut()
	
	bouton_suivant.pressed.connect(_on_bouton_suivant_pressed)
	bouton_suivant.visible = false
	
	afficher_question()

func charger_questions_depuis_exports():
	# Vérifier que tous les arrays ont la même taille
	if phrases.size() != reponses_correctes.size() or phrases.size() != verbes.size():
		print("Erreur: Les arrays phrases, reponses_correctes et verbes doivent avoir la même taille!")
		return
	
	# Créer les questions depuis les arrays exportés
	for i in range(phrases.size()):
		var question = Question.new(phrases[i], reponses_correctes[i], verbes[i])
		questions.append(question)
	
	mettre_a_jour_barre_progression()

func creer_questions_defaut():
	# Exemples de questions pour "avoir"
	var q1 = Question.new("Je ___ un chat", "ai", "avoir")
	questions.append(q1)
	
	var q2 = Question.new("Tu ___ une voiture", "as", "avoir")
	questions.append(q2)
	
	var q3 = Question.new("Il ___ gentil", "est", "être")
	questions.append(q3)
	
	var q4 = Question.new("Nous ___ contents", "sommes", "être")
	questions.append(q4)

	mettre_a_jour_barre_progression()
	
func afficher_question():
	if question_actuelle >= questions.size():
		fin_du_jeu()
		return
	
	var question = questions[question_actuelle]
	label_phrase.text = question.phrase
	
	# Nettoyer les anciens boutons
	for bouton in boutons_conjugaison:
		bouton.queue_free()
	boutons_conjugaison.clear()
	
	# Créer les boutons selon le verbe
	var conjugaisons: Array[String]
	if question.verbe == "être":
		conjugaisons = conjugaisons_etre
	else:  # avoir
		conjugaisons = conjugaisons_avoir
	
	# Mélanger les conjugaisons pour plus de difficulté
	conjugaisons = conjugaisons.duplicate()
	conjugaisons.shuffle()
	
	# Créer un bouton pour chaque conjugaison
	for conjugaison in conjugaisons:
		var bouton = Button.new()
		bouton.text = conjugaison
		bouton.custom_minimum_size = Vector2(80, 40)
		bouton.pressed.connect(_on_conjugaison_choisie.bind(conjugaison))
		
		container_boutons.add_child(bouton)
		boutons_conjugaison.append(bouton)
	
	# Cacher le bouton suivant
	bouton_suivant.visible = false
	
	# Activer tous les boutons
	for bouton in boutons_conjugaison:
		bouton.disabled = false
	
	mettre_a_jour_barre_progression()

func mettre_a_jour_barre_progression():
	if barre_progression and questions.size() > 0:
		# Si on a dépassé le nombre de questions, mettre à 100%
		if question_actuelle >= questions.size():
			barre_progression.value = 100
		else:
			var progres = (float(question_actuelle) / float(questions.size())) * 100
			barre_progression.value = progres
	
		
func _on_conjugaison_choisie(conjugaison: String):
	var question = questions[question_actuelle]
	var est_correct = (conjugaison == question.reponse_correcte)
	
	if est_correct:
		score += 1
		#print("Correct ! ✓")
		# Mettre le bouton correct en vert
		for bouton in boutons_conjugaison:
			if bouton.text == conjugaison:
				bouton.modulate = Color.GREEN
	else:
		#print("Incorrect ! ✗")
		# Mettre le bouton incorrect en rouge et montrer la bonne réponse
		for bouton in boutons_conjugaison:
			if bouton.text == conjugaison:
				bouton.modulate = Color.RED
			elif bouton.text == question.reponse_correcte:
				bouton.modulate = Color.GREEN
	
	# Désactiver tous les boutons
	for bouton in boutons_conjugaison:
		bouton.disabled = true
	
	# Afficher le score et le bouton suivant
	mettre_a_jour_score()
	bouton_suivant.visible = true

func mettre_a_jour_score():
	label_score.text = "Score: %d/%d" % [score, question_actuelle + 1]

func _on_bouton_suivant_pressed():
	question_actuelle += 1
	afficher_question()

func fin_du_jeu():
	if barre_progression:
		barre_progression.value = 100
	label_phrase.text = "Félicitations ! Jeu terminé !"
	var nombre_total_questions = questions.size()
	# Cacher tous les boutons de conjugaison
	for bouton in boutons_conjugaison:
		bouton.visible = false
	if score < nombre_total_questions:
		bouton_suivant.text = "Recommencer"
	elif score == nombre_total_questions:
		bouton_suivant.text = "Sortie"
	bouton_suivant.visible = true
	bouton_suivant.pressed.disconnect(_on_bouton_suivant_pressed)
	bouton_suivant.pressed.connect(recommencer_jeu)

func recommencer_jeu():
	if bouton_suivant.text == "Recommencer":
		question_actuelle = 0
		score = 0
		bouton_suivant.text = "Suivant"
		bouton_suivant.pressed.disconnect(recommencer_jeu)
		bouton_suivant.pressed.connect(_on_bouton_suivant_pressed)
		mettre_a_jour_barre_progression()
		afficher_question()
	else:
		game_over.emit()
		hide()


func _on_button_exit_pressed() -> void:
	hide()
	exited.emit()
