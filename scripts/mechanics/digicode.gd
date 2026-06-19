extends Area3D


@export var door_gate_to_open_nbr :=-1
@export_enum("typing", "spelling", "conjug", "qcm") var test_type: String
@export var disapear := false
@export var repeatable : bool = true
@export var press_elbl : Label3D
@onready var game_1: CanvasLayer = $game1
@onready var game_2: CanvasLayer = $game2



var player : CharacterBody3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.show()
		player = body


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.hide()
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elbl.visible and player != null:
		player.can_move = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if test_type == "qcm":
			game_2.show()
			game_1.hide()
		else:
			game_1.show()
			game_2.hide()
		


func _on_cast_game_letters_end() -> void:
	game_1.hide()
	game_2.hide()
	get_tree().paused = false
	if player:
		player.can_move = true
	Global.emit_open_door_gate(door_gate_to_open_nbr)
	if not repeatable:
		set_deferred("monitoring", false)


func _on_cast_game_letters_exited() -> void:
	game_1.hide()
	game_2.hide()
	get_tree().paused = false
	if player:
		player.can_move = true
