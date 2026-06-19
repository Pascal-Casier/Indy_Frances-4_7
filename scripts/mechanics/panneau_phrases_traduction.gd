extends Node3D

@export var door_nbr : int = -1
var player = null
@onready var press_e_lbl: Label3D = %PressELbl
@onready var traduction_choice_game: Control = $Traduction_choice_game

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_lbl.visible:
		if player:
			player.can_move = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		traduction_choice_game.show()
		traduction_choice_game.start_quiz()
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_lbl.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_lbl.hide()


func _on_traduction_choice_game_game_over() -> void:
	if player:
		player.can_move = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	traduction_choice_game.hide()
	Global.emit_open_door_gate(door_nbr)
	
