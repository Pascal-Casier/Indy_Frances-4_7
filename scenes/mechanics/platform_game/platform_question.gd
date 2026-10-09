class_name QuizQuestion
extends Resource
## Une question du quiz. Créez-en dans l'inspecteur : Nouvelle ressource > QuizQuestion.

@export_multiline var text: String = ""
## Une réponse par dalle (le nombre doit correspondre au nombre de dalles de la plateforme).
@export var answers: Array[String] = ["", "", ""]
## Index (0, 1, 2...) de la bonne réponse dans `answers`.
@export var correct_index: int = 0
## Texte de feedback optionnel affiché après la réponse (laisser vide pour le texte par défaut).
@export_multiline var explanation: String = ""
