extends Area3D

@export var doorNbr : int = -1
@onready var match_words_game: Control = $MatchWordsGame
var player : CharacterBody3D


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		player.can_move = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		match_words_game.show()


func _on_match_words_game_success() -> void:
	if player:
		player.can_move = true
	Global.emit_open_door_gate(doorNbr)
	player = null
	queue_free()


		
