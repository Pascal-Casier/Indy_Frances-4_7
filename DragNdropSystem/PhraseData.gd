@tool
extends Resource
class_name PhraseData

## Une phrase avec des trous à remplir.
## Les TROU dans `tokens` correspondent dans l'ordre aux `answers`.

## Les mots de la phrase — écrire "TROU" pour chaque mot manquant
## Exemple : ["Le", "TROU", "saute", "par-dessus", "TROU", "clôture", "."]
@export var tokens: PackedStringArray = []

## Les bonnes réponses, dans l'ordre des TROU
## Exemple : ["chat", "la"]
@export var answers: PackedStringArray = []

## Mots pièges supplémentaires affichés dans le word bank
## Exemple : ["chien", "mange", "une"]
@export var distractors: PackedStringArray = []
