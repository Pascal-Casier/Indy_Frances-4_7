# res://resources/dialogue_entry.gd
@tool
extends Resource
class_name DialogueEntry

## Phrase originale — supporte le BBCode
## Ex: "Il fait [color=royalblue]beau[/color] aujourd'hui."
@export_multiline var original_text: String = ""

## Traduction correcte en portugais
@export_multiline var correct_translation: String = ""

## Traduction incorrecte (le leurre)
@export_multiline var wrong_translation: String = ""

## Photo de la personne qui parle (optionnelle)
@export var speaker_picture: Texture2D = null

@export var spoken_audio: AudioStream = null
