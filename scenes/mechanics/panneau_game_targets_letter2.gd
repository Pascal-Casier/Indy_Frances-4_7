extends Node3D

@export var door_nbr : int = -1

# Dictionnaire modifiable dans l'inspecteur
@export var dictionnaire_traduction: Dictionary[String, String] = {
	"GATO": "CHAT",
	"CHIEN": "CÃO",
	"MAISON": "CASA"
}

var cles_mots: Array = []
var index_mot_actuel: int = 0

var mot_portugais: String = ""
var mot_cible: String = ""
var progression: String = ""

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var text_2: Label3D = %Text2         # Pour afficher l'indice (le mot en portugais)
@onready var text_answer: Label3D = %TextAnswer # Pour afficher la progression du joueur

const CORRECT_2 = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect2.ogg")
const VICTORY = preload("res://assets/sounds/musics/Victory.ogg")

func _ready():
	cles_mots = dictionnaire_traduction.keys()
	if cles_mots.is_empty():
		push_error("Le dictionnaire de traduction est vide !")
		return
	
	index_mot_actuel = 0
	charger_mot_actuel()

func charger_mot_actuel():
	if index_mot_actuel >= cles_mots.size():
		text_2.text = "TERMINÉ !"
		text_answer.text = ""
		Global.emit_open_door_gate(door_nbr)
		audio_stream_player.stream = VICTORY
		audio_stream_player.play()
		return

	mot_portugais = cles_mots[index_mot_actuel]
	mot_cible = dictionnaire_traduction[mot_portugais]
	progression = ""
	
	text_2.text = mot_portugais.to_upper()
	text_answer.text = ""

	var cibles = get_tree().get_nodes_in_group("target_letter")
	
	if cibles.size() < mot_cible.length():
		push_error("Il n'y a pas assez de cibles ('target_letter') pour le mot français : " + mot_cible + " (Requises : " + str(mot_cible.length()) + ", Disponibles : " + str(cibles.size()) + ")")
		return

	var lettres_a_distribuer = []
	for i in range(mot_cible.length()):
		lettres_a_distribuer.append(mot_cible[i])
	
	lettres_a_distribuer.shuffle()

	# Activer/configurer les cibles nécessaires et désactiver les autres
	for i in range(cibles.size()):
		var cible = cibles[i]
		if i < lettres_a_distribuer.size():
			if "lettre" in cible:
				cible.lettre = lettres_a_distribuer[i]
			
			# On active la cible
			if cible.has_method("set_actif"):
				cible.set_actif(true)
				
			if not cible.cible_touchee.is_connected(on_cible_touchee):
				cible.cible_touchee.connect(on_cible_touchee)
		else:
			# On désactive et cache la cible en trop
			if "lettre" in cible:
				cible.lettre = ""
				
			if cible.has_method("set_actif"):
				cible.set_actif(false)

func on_cible_touchee(lettre: String):
	if index_mot_actuel >= cles_mots.size():
		return

	var attendu = mot_cible[progression.length()]
	if lettre.to_upper() == attendu:
		progression += lettre.to_upper()
		text_answer.text = progression
		audio_stream_player.stream = CORRECT_2
		audio_stream_player.play()
		
		if progression == mot_cible:
			audio_stream_player.stream = VICTORY
			audio_stream_player.play()
			index_mot_actuel += 1
			charger_mot_actuel()
	else:
		progression = ""
		text_answer.text = progression
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
