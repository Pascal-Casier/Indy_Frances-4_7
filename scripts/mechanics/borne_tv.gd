extends StaticBody3D
class_name BorneTV

@export var door_nb : int = -1
@onready var control: Control = $Control
@onready var press_e: Label3D = %PressE
@onready var phrase_maker_ui: CanvasLayer = $Control/Phrase_maker_UI
@onready var area_3d: Area3D = $Area3D

var player = null


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible:
		player.can_move = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		control.show()
		phrase_maker_ui.show()
		

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()
		

func _on_phrase_maker_ui_kill_parent() -> void:
	if player:
		player.can_move = true
		#get_tree().paused = false
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#control.hide()
		
func success() -> void:
	Global.emit_open_door_gate(door_nb)
	area_3d.monitoring = false

func _on_phrase_maker_ui_exit() -> void:
	if player:
		player.can_move = true

func _on_phrase_maker_ui_success() -> void:
	success()
