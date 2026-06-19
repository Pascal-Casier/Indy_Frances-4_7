extends Node3D

@export var word_to_find : String = ""
@export var door_to_open := 0
var answer : String = ""

func _ready() -> void:
	for c in get_children():
		c.on_letter_found.connect(_letter_added)
		
#func _letter_added(letter : String):
	#letter.to_lower()
	#answer += letter
	#if answer == word_to_find :
		#Global.emit_open_door_gate(door_to_open)
func _letter_added(letter: String):
	letter = letter.to_lower()
	answer += letter

	if _is_correct_answer():
		Global.emit_open_door_gate(door_to_open)

func _is_correct_answer() -> bool:
	if answer.length() != word_to_find.length():
		return false

	var answer_letters = answer.split("")
	answer_letters.sort()

	var word_letters = word_to_find.split("")
	word_letters.sort()

	return answer_letters == word_letters
