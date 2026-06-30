# QuestionPanel.gd
extends Control

@onready var label_question = %Label
@onready var boutons = []
@onready var button_1: Button = %Button1
@onready var button_2: Button = %Button2
@onready var button_3: Button = %Button3


func _ready() -> void:
	boutons.append(button_1)
	boutons.append(button_2)
	boutons.append(button_3)
	
func afficher_question(question: QuestionData) -> void:
	visible = true
	label_question.text = question.texte_question
	for i in range(3):
		boutons[i].text = question.reponses[i]
	# Le joueur n'a pas besoin de cliquer : il pilote vers la bonne porte
	await get_tree().create_timer(10).timeout
	visible = false  # ou laisse le panel affiché pendant qu'il roule vers les portes
