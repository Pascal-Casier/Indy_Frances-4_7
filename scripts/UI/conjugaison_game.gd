extends Control

signal game_over
signal exited

# ===========================
#      EXPORT VARIABLES
# ===========================
@export_group("Questions")
@export var phrases: Array[String] = []               # Ex: "Je ___ un livre"
@export var reponses_pronoms: Array[String] = []      # Optionnel : ex "je", "tu", "il" ...
@export var reponses_correctes: Array[String] = []    # Optionnel : ex "parle", "mange" ...
@export var verbes: Array[String] = []                # Ex: "parler", "être"

# Conjugaisons pour être / avoir
@export_group("Conjugaisons spéciales")
@export var conjugaisons_etre := ["suis","es","est","sommes","êtes","sont"]
@export var conjugaisons_avoir := ["ai","as","a","avons","avez","ont"]

# ===========================
#         QUESTION CLASS
# ===========================
class Question:
	var phrase: String = ""
	var pronom: String = ""         # ex "je" (si fourni) ou calculé depuis reponses_correctes
	var reponse_correcte: String = "" # forme (ex "parle") si fournie
	var verbe: String = ""

	func _init(p_phrase: String = "", p_pronom: String = "", p_reponse: String = "", p_verbe: String = ""):
		phrase = p_phrase
		pronom = p_pronom
		reponse_correcte = p_reponse
		verbe = p_verbe

# ===========================
#        GAME VARIABLES
# ===========================
var questions: Array[Question] = []
var question_actuelle: int = 0
var score: int = 0
var boutons_conjugaison: Array[Button] = []

# Node references (adapte si noms différents)
@onready var label_phrase = %PhraseLabel
@onready var container_boutons = %BoutonsContainer
@onready var label_score = %ScoreLabel
@onready var bouton_suivant = %BoutonSuivant
@onready var barre_progression: ProgressBar = %BarreProgression
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const CORRECT = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECT = preload("res://assets/sounds/sfx/incorrect2.ogg")
# Pronoms / sujets (ordre fixe)
var pronoms := ["je","tu","il","nous","vous","ils"]

# ===========================
#           READY
# ===========================
func _ready():
	# initialise la barre si présente
	if barre_progression:
		barre_progression.min_value = 0
		barre_progression.max_value = 100
		barre_progression.value = 0
		barre_progression.show_percentage = false

	charger_questions()
	bouton_suivant.visible = false
	if not bouton_suivant.is_connected("pressed", Callable(self, "_on_bouton_suivant_pressed")):
		bouton_suivant.pressed.connect(_on_bouton_suivant_pressed)
	afficher_question()


# ===========================
#    LOAD / BUILD QUESTIONS
# ===========================
func charger_questions():
	questions.clear()

	# Vérifier cohérence minimale
	if phrases.size() == 0:
		push_warning("Aucune phrase fournie.")
		return

	# Deux cas possibles d'entrée :
	# - l'utilisateur remplit reponses_pronoms (ex: "je")
	# - ou il remplit reponses_correctes (ex: "parle")
	# Si les deux sont remplis, reponses_pronoms a priorité.

	var use_pronoms: bool = (reponses_pronoms.size() == phrases.size())
	var use_formes: bool = (reponses_correctes.size() == phrases.size())

	if not use_pronoms and not use_formes:
		push_warning("Tu dois fournir soit 'reponses_pronoms' soit 'reponses_correctes', avec la même taille que 'phrases'.")
		# On tentera de charger avec des valeurs vides pour éviter crash
		for i in range(phrases.size()):
			var p = ""
			var f = ""
			var v = ""
			if i < verbes.size():
				v = verbes[i]
			questions.append(Question.new(phrases[i], p, f, v))
		return

	for i in range(phrases.size()):
		var p = ""
		var f = ""
		if use_pronoms:
			p = reponses_pronoms[i].strip_edges().to_lower()
		if use_formes:
			f = reponses_correctes[i].strip_edges()
		var v = ""
		if i < verbes.size():
			v = verbes[i].strip_edges().to_lower()
		questions.append(Question.new(phrases[i], p, f, v))

	mettre_a_jour_barre_progression()


# ===========================
#     GENERER CONJUGAISON
# ===========================
func generer_conjugaison(verbe: String) -> Array[String]:
	verbe = verbe.strip_edges().to_lower()
	if verbe == "être":
		return conjugaisons_etre.duplicate()
	if verbe == "avoir":
		return conjugaisons_avoir.duplicate()
	if verbe.ends_with("er"):
		if verbe.length() < 3:
			return ["","","","","",""]
		var racine = verbe.substr(0, verbe.length() - 2)
		return [
			racine + "e",
			racine + "es",
			racine + "e",
			racine + "ons",
			racine + "ez",
			racine + "ent"
		]
	# verbe inconnu
	return []


# ===========================
#     AFFICHER QUESTION
# ===========================
func afficher_question():
	if question_actuelle >= questions.size():
		fin_du_jeu()
		return

	var q = questions[question_actuelle]
	label_phrase.text = q.phrase

	# Nettoyer anciens boutons
	for b in boutons_conjugaison:
		if is_instance_valid(b):
			b.queue_free()
	boutons_conjugaison.clear()

	# Générer formes
	var formes = generer_conjugaison(q.verbe)
	if formes.size() != 6:
		push_warning("Impossible de conjuguer '%s'." % q.verbe)
		return

	# Trouver la bonne forme (par le pronom ou la forme directe)
	var idx_bon = pronoms.find(q.pronom)
	var bonne_forme = formes[idx_bon]

	# Construire liste des mauvaises formes, sans doublons exacts
	var mauvaises = []
	for f in formes:
		if f != bonne_forme and not mauvaises.has(f):
			mauvaises.append(f)

	# Choisir 2 mauvaises au hasard
	mauvaises.shuffle()
	var mauvaises_choisies = mauvaises.slice(0, 2)

	# Créer option finale : 3 boutons (1 bon + 2 mauvais)
	var options = [bonne_forme] + mauvaises_choisies
	options.shuffle()

	# Création boutons
	for f in options:
		var btn = Button.new()
		btn.text = f
		btn.custom_minimum_size = Vector2(110, 42)
		btn.pressed.connect(_on_conjugaison_choisie.bind(btn))
		container_boutons.add_child(btn)
		boutons_conjugaison.append(btn)

	# Reset UI
	bouton_suivant.visible = false
	for b in boutons_conjugaison:
		b.disabled = false
		b.modulate = Color(1,1,1)

	mettre_a_jour_barre_progression()
	mettre_a_jour_score()



# ===========================
#   QUAND L'UTILISATEUR CHOISIT
# ===========================
func _on_conjugaison_choisie(btn: Button):
	var q = questions[question_actuelle]

	var idx_bon = pronoms.find(q.pronom)
	var bonne_forme = generer_conjugaison(q.verbe)[idx_bon]

	var est_correct = (btn.text == bonne_forme)

	# Couleurs
	for b in boutons_conjugaison:
		b.disabled = true
		if b.text == bonne_forme:
			b.modulate = Color.GREEN
		elif b == btn and not est_correct:
			b.modulate = Color.RED

	if est_correct:
		score += 1
		audio_stream_player.stream = CORRECT
		audio_stream_player.play()
	else :
		audio_stream_player.stream = INCORRECT
		audio_stream_player.play()

	mettre_a_jour_score()
	bouton_suivant.visible = true



# ===========================
#   MISE A JOUR SCORE / UI
# ===========================
func mettre_a_jour_score():
	label_score.text = "Score : %d/%d" % [score, question_actuelle + 1]

func _on_bouton_suivant_pressed():
	question_actuelle += 1
	afficher_question()

func mettre_a_jour_barre_progression():
	if questions.size() == 0:
		return
	barre_progression.value = float(question_actuelle) / float(questions.size()) * 100.0

func fin_du_jeu():
	var total = questions.size()
	var pourcentage = float(score) / float(total) * 100.0

	# Effacer les boutons
	for b in boutons_conjugaison:
		b.visible = false

	bouton_suivant.visible = true
	bouton_suivant.pressed.disconnect(_on_bouton_suivant_pressed)

	# Condition de réussite
	if pourcentage >= 70.0:
		label_phrase.text = "🎉 Félicitations ! Tu as réussi (%d%%) !" % int(pourcentage)
		bouton_suivant.text = "Sortir"
		bouton_suivant.pressed.connect(_sortir_jeu)
	else:
		label_phrase.text = "❌ Tu n'as que %d%%. Tu dois recommencer !" % int(pourcentage)
		bouton_suivant.text = "Recommencer"
		bouton_suivant.pressed.connect(_recommencer_partie)
	
	mettre_a_jour_barre_progression()

func _recommencer_partie():
	score = 0
	question_actuelle = 0
	bouton_suivant.pressed.disconnect(_recommencer_partie)
	bouton_suivant.text = "Suivant"
	bouton_suivant.pressed.connect(_on_bouton_suivant_pressed)
	afficher_question()

func _sortir_jeu():
	game_over.emit()
	hide()


func recommencer_jeu():
	game_over.emit()
	hide()

func _on_button_exit_pressed() -> void:
	hide()
	exited.emit()
