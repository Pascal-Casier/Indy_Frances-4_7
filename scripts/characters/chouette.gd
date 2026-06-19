extends StaticBody3D

@onready var press_e: Label3D = %PressE
@export var timeline_name : String = "test1"
@export var disapear := false
@export var door_gate_to_open_nbr : int = 0
var player : CharacterBody3D = null



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible and player != null:
		player.can_move = false
		#player.set_physics_process(false)
		start_dialog()
		
func start_dialog():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Dialogic.current_timeline != null:
		return
	Dialogic.start(timeline_name)
	get_viewport().set_input_as_handled()
	Dialogic.signal_event.connect(_on_signal_event)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_ended():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	Dialogic.signal_event.disconnect(_on_signal_event)
	#player.set_physics_process(true)
	player.can_move = true
	player = null
	if disapear:
		queue_free()

func _on_signal_event(argument : String) -> void:
	if argument == "open_gate":
		Global.emit_open_door_gate(door_gate_to_open_nbr)
		
