extends Node3D

@export var word_to_find : String = "table"
@export var door_nbr : int = 0
var word_length : int = 0

func _ready() -> void:
	pass

func _on_crate_catcher_1_on_letter_found(extra_arg_0: String) -> void:
	if extra_arg_0 in word_to_find:
		word_length +=1
		if word_length == word_to_find.length():
			Global.emit_open_door_gate(door_nbr)
