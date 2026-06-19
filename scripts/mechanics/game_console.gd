extends Node3D

enum game_type {TRAD, CONJ}
@export var door_gate_to_open_nbr := -1
@export var game_to_show : game_type
@onready var press_elabel: Label3D = %PressElabel
@onready var code_finder_letters_to_words: CanvasLayer = $CodeFinder_letters_to_words
@onready var conjugaison_game: Control = $ConjugaisonGame

var player = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elabel.show()
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elabel.hide()
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elabel.visible and player != null:
		player.can_move = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if game_to_show == game_type.TRAD:
			code_finder_letters_to_words.show()
		else:
			conjugaison_game.show()
		
func _on_cast_game_letters_end() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player:
		player.can_move = true
	Global.emit_open_door_gate(door_gate_to_open_nbr)
	%Area3D.set_deferred("monitoring", false)
	


func _on_conjugaison_game_exited() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player:
		player.can_move = true
