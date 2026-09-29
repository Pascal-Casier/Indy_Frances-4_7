class_name TranslationExercise
extends Resource

## La phrase d'origine en français
@export_multiline var french_sentence: String = ""

## La séquence exacte de mots qui forment la traduction correcte
@export var correct_tokens: Array[String] = []

## Mots pièges/intrus supplémentaires à ajouter dans la liste
@export var distractor_tokens: Array[String] = []
