# QuestionData.gd
extends Resource
class_name QuestionData

@export var texte_question: String
@export var indice: String
@export var reponses: Array[String] = ["", "", ""]
@export var index_bonne_reponse: int = 0
