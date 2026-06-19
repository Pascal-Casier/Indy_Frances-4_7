#
#
### Dans ton script de niveau
##func _ready():
	### Panneau ÊTRE
	##panneau_1.definir_phrase("Je suis un explorateur.", "suis")
	##panneau_1.verbe_trouve.connect(_on_verbe_trouve)
##
##func _on_verbe_trouve(verbe: String):
	##print("✅ Verbe trouvé : ", verbe)
	### Ouvre la statue / porte
	##ouvrir_porte()


@tool
extends Control
class_name PanneauVerbeSequence

@export var title : String = "test"
# ==================== CONFIGURATION ====================
@export_group("Séquence de Phrases")
@export var phrases : Array[String] = [
	"Je _____ un explorateur.",
	"Tu _____ un fouet.",
	"Nous _____ au temple."
] : set = _set_phrases

@export var verbes_corrects : Array[String] = [
	"suis",
	"as",
	"allons"
] : set = _set_verbes

@export_group("Affichage")
@export var couleur_correct : Color = Color.GREEN
@export var couleur_erreur  : Color = Color.RED
@export var temps_feedback  : float = 2.0

@export_group("Sons")
@export var son_correct : AudioStream
@export var son_erreur  : AudioStream

# ==================== VARIABLES INTERNES ====================
var index_actuel : int = 0
var total_phrases : int = 0
var reponse_correcte : bool = false
var _pret_pour_affichage : bool = false  # <-- NOUVEAU

# ==================== NODES ====================
@onready var label_phrase    : Label   = %Label
@onready var line_edit       : LineEdit = %LineEdit
@onready var btn_valider     : Button  = %ButtonValider
@onready var label_feedback  : Label   = %LabelFeedback
@onready var audio_player    : AudioStreamPlayer = $AudioStreamPlayer

# ==================== SETTERS (UNIQUEMENT synchronisation) ====================
func _set_phrases(nouvelles_phrases: Array[String]) -> void:
	phrases = nouvelles_phrases
	_synchroniser_taille()
	# ON NE TOUCHE PLUS AUX NŒUDS ICI !

func _set_verbes(nouveaux_verbes: Array[String]) -> void:
	verbes_corrects = nouveaux_verbes
	_synchroniser_taille()
	# ON NE TOUCHE PLUS AUX NŒUDS ICI !

func _synchroniser_taille() -> void:
	total_phrases = mini(phrases.size(), verbes_corrects.size())
	while phrases.size() < verbes_corrects.size():
		phrases.append("")
	while verbes_corrects.size() < phrases.size():
		verbes_corrects.append("")

# ==================== READY ====================
func _ready() -> void:
	# Vérification de sécurité
	if not label_phrase: push_error("Label manquant !")
	if not line_edit: push_error("LineEdit manquant !")
	if not btn_valider: push_error("ButtonValider manquant !")
	if not label_feedback: push_error("LabelFeedback manquant !")
	%TitleLabel.text = title

	if btn_valider:
		btn_valider.pressed.connect(_on_valider_pressed)
	if line_edit:
		line_edit.text_submitted.connect(_on_enter_pressed)
	
	_synchroniser_taille()
	
	# ON ACTIVE L'AFFICHAGE UNIQUEMENT APRÈS _ready
	_pret_pour_affichage = true
	charger_phrase_actuelle()  # Maintenant sûr !

# ==================== CHARGEMENT DE PHRASE ====================
func charger_phrase_actuelle() -> void:
	if not _pret_pour_affichage:
		return  # Sécurité

	if index_actuel >= total_phrases:
		_tout_fini()
		return
	
	if label_phrase:
		label_phrase.text = phrases[index_actuel]
	if line_edit:
		line_edit.text = ""
		line_edit.grab_focus()
	reponse_correcte = false
	if label_feedback:
		label_feedback.text = ""

# ==================== VALIDATION ====================
func _on_valider_pressed() -> void:
	if index_actuel >= total_phrases or not line_edit:
		return
		
	var reponse = line_edit.text.strip_edges().to_lower()
	var verbe_attendu = verbes_corrects[index_actuel].to_lower()
	
	if reponse == verbe_attendu:
		_afficher_correct()
	else:
		_afficher_erreur()

func _on_enter_pressed(_texte: String) -> void:
	_on_valider_pressed()

# ==================== FEEDBACK ====================
func _afficher_correct() -> void:
	reponse_correcte = true
	if label_feedback:
		label_feedback.text = "PARFAIT !"
		label_feedback.modulate = couleur_correct
	
	if son_correct and audio_player:
		audio_player.stream = son_correct
		audio_player.play()
	
	_creer_anim_succes()
	
	get_tree().create_timer(temps_feedback).timeout.connect(_passer_suivant)

func _afficher_erreur() -> void:
	if label_feedback:
		label_feedback.text = "Essaie encore !"
		label_feedback.modulate = couleur_erreur
	
	if son_erreur and audio_player:
		audio_player.stream = son_erreur
		audio_player.play()
	
	get_tree().create_timer(1.0).timeout.connect(func():
		if label_feedback: label_feedback.text = ""
		if line_edit: line_edit.text = ""
	)

func _passer_suivant() -> void:
	index_actuel += 1
	charger_phrase_actuelle()

func _tout_fini() -> void:
	if not _pret_pour_affichage: return
	if label_phrase:
		label_phrase.text = "BRAVO ! Toutes les phrases sont correctes !"
	if line_edit:
		line_edit.editable = false
	if btn_valider:
		btn_valider.disabled = true
	if label_feedback:
		label_feedback.text = "Terminé !"
		label_feedback.modulate = Color.GOLD
	
	sequence_terminee.emit()

# ==================== ANIMATION ====================
func _creer_anim_succes() -> void:
	if not label_phrase: return
	var tween = create_tween()
	tween.tween_property(label_phrase, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(label_phrase, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.1)

# ==================== SIGNAUX ====================
signal sequence_terminee

# ==================== FONCTIONS PUBLIQUES ====================
func reset_sequence() -> void:
	index_actuel = 0
	if line_edit:
		line_edit.editable = true
	if btn_valider:
		btn_valider.disabled = false
	charger_phrase_actuelle()

func est_fini() -> bool:
	return index_actuel >= total_phrases


func _on_button_exit_pressed() -> void:
	hide()
