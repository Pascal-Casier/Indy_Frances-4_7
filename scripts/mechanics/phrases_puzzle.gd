extends Node3D

@export var phrasePT : String = "Ele não trabalha comigo"
@export var phraseFR : String = "Il ne travaille pas avec moi"
@export var door_nbr : int = -1

@onready var lbl_pt_1: Label3D = $lblPT1
@onready var lbl_fr: Label3D = $lblFR
@onready var dalles: Node3D = $dalles
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const CORRECT_ANSWER = preload("res://assets/sounds/sfx/correct_answer.mp3")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect2.ogg")

var new_phrase : String

var phrase_target: PackedStringArray
var current_phrase: PackedStringArray = []


func _ready() -> void:
	phrase_target = phraseFR.split(" ")
	#lbl_fr.text = ""
	lbl_pt_1.text = phrasePT
	lbl_fr.text = "..."
	for d in dalles.get_children():
		if d is Dalle_phrase:
			d.text_emit.connect(_on_dalle_stepped)

func _on_dalle_stepped(t:String) -> void:
	var index = current_phrase.size()
	if index >= phrase_target.size():
		return  # Trop de mots, on ignore
	if t == phrase_target[index]:
		current_phrase.append(t)
		lbl_fr.text = " ".join(current_phrase)
		
		
		if current_phrase.size() == phrase_target.size():
			# Phrase complète et correcte
			lbl_fr.text += " ✅"
			audio_stream_player.stream = CORRECT_ANSWER
			audio_stream_player.play()
			Global.emit_open_door_gate(door_nbr)
			# Tu peux ajouter ici un signal ou effet de victoire
	else:
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
		# Mauvais mot → on réinitialise
		current_phrase.clear()
		lbl_fr.text = "❌ Erreur. Recommence."
		await get_tree().create_timer(2).timeout
		for d in dalles.get_children():
			d.reset()
		
	
	
