extends Area3D

@onready var lbl_press_e: Label3D = $lblPressE
@onready var quizz: Control = $Quizz
@export	 var door_nbr : int = 0
@onready var contour: MeshInstance3D = $Terminal1_lambert1_0/contour
@onready var contour_2: MeshInstance3D = $Terminal1_lambert1_0/ComputerCartoon/Cube/contour2
var player : CharacterBody3D = null

func _ready() -> void:
	quizz.door_number = door_nbr

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.show()
		contour.show()
		contour_2.show()
		player = body


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.hide()
		contour.hide()
		contour_2.hide()
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and lbl_press_e.visible:
		quizz.show()
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if player:
			player.can_move = false
		


func _on_quizz_success(_b) -> void:
	Global.emit_open_door_gate(door_nbr)
	if player:
		player.can_move = true
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_quizz_exited() -> void:
	if player:
		player.can_move = true
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
