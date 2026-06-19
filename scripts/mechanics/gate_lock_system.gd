extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var press_elbl: Label3D = $ordinateur1/Cube/pressElbl
@onready var quizz: Control = $Quizz
@onready var ordinateur_1: Area3D = $ordinateur1
@onready var contour: MeshInstance3D = $ordinateur1/Cube/contour
var player = null

func open_gate(_index:int) ->void:
	animation_player.play("open_gate")
	if player: 
		player.can_move = true
	get_tree().paused = false
	ordinateur_1.monitoring = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elbl.visible:
		begin_quizz()
		
	
func _on_ordinateur_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.show()
		contour.show()
		player = body


func _on_ordinateur_1_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.hide()
		contour.hide()
		player = null
		
func begin_quizz():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if player :
		player.can_move = false
	get_tree().paused = true
	
	quizz.show()
	quizz.start_new_quizz()


func _on_quizz_exited() -> void:
	if player :
		player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
