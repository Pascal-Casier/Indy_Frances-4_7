extends Area3D
class_name BorneTV2

@export var door_nbr : int = -1
@onready var press_elbl: Label3D = %PressElbl
@onready var wheels_game_riddle: Control = $Wheels_game_riddle
var player : CharacterBody3D = null


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		press_elbl.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = null
		press_elbl.hide()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elbl.visible:
		wheels_game_riddle.mouse_filter = Control.MOUSE_FILTER_STOP
		get_tree().paused = true
		if player:
			player.can_move = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		wheels_game_riddle.show()


func _on_wheels_game_riddle_success() -> void:
	wheels_game_riddle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	press_elbl.hide()
	monitoring = false
	Global.emit_open_door_gate(door_nbr)
