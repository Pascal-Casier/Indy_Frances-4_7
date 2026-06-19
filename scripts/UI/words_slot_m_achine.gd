extends Control

# Exemple de données
var phrases = [
	["Hello", "Hi", "Greetings"],
	["from", "with", "by"],
	["Godot", "the engine", "the community"]
]
# Exemple d'initialisation de la machine à sous avec trois rouleaux
var reel1 : Array = phrases[0]
var reel2 : Array = phrases[1]
var reel3 : Array = phrases[2]

var current_index
var current_index1 : int = 0
var current_index2 : int = 0
var current_index3 : int = 0

func scroll_reel(reel : Array, index : int) -> void:
	# Faites défiler le rouleau
	index = (current_index + 1) % reel.size()
	# Mettez à jour le texte du Label correspondant
	%Label1.text = reel[index]

func form_sentence() -> void:
	var sentence = "%s %s %s" % [reel1[current_index1], reel2[current_index2], reel3[current_index3]]
	print(sentence)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		scroll_reel(reel1, current_index1)
		scroll_reel(reel2, current_index2)
		scroll_reel(reel3, current_index3)
	elif event.is_action_pressed("aim"):
		form_sentence()
