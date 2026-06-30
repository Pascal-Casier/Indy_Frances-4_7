# GameManager.gd
extends Node

@onready var question_panel = %QuestionPanel
@onready var timer_label = %Timer


var temps_restant: float = 120.0
var jeu_en_cours: bool = true

func _ready() -> void:
	for trigger in get_tree().get_nodes_in_group("question_triggers"):
		trigger.question_declenchee.connect(_on_question_declenchee)

func _process(delta: float) -> void:
	if jeu_en_cours:
		temps_restant -= delta
		timer_label.text = "%02d:%02d" % [int(temps_restant) / 60, int(temps_restant) % 60]
		if temps_restant <= 0:
			perdre()

func _on_question_declenchee(question: QuestionData, porte_groupe: Node3D) -> void:
	# Met à jour les portes avec la bonne réponse
	for i in range(porte_groupe.get_child_count()):
		porte_groupe.get_child(i).index_bonne_reponse_courante = question.index_bonne_reponse
		porte_groupe.get_child(i).set_texte_reponse(question.reponses[i])
	question_panel.afficher_question(question)

func ligne_arrivee_atteinte() -> void:
	jeu_en_cours = false
	if temps_restant > 0:
		gagner()
	else:
		perdre()

func gagner() -> void:
	print("Victoire ! Temps restant : ", temps_restant)

func perdre() -> void:
	print("Défaite")
