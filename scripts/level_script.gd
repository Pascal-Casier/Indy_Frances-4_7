extends Node

@export var level_number : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.niveau_number = level_number
	SaveSystem.save_game(1)
