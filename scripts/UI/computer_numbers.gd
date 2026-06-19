extends Area3D

@export var my_sound_list: Array[AudioStream] = []
@export var my_answers: Array[String] = []  # ex: ["3", "42", "7", "156"]

@export var door_nbr : int = -1
@onready var number_test: Control = $NumberTest
@onready var press_elbl: Label3D = $PressElbl
var player : CharacterBody3D

func _ready() -> void:
	if number_test:
		number_test.sound_list = my_sound_list
		number_test.answers = my_answers

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.show()
		player = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
			press_elbl.hide()
			player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elbl.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		if player:
			player.can_move = false
		number_test.show()
		number_test._load_round()
			
func _on_number_test_success() -> void:
	number_test.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	if player:
		player.can_move = true
	Global.emit_open_door_gate(door_nbr)
