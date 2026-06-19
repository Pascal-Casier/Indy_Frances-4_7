extends Control

func _ready() -> void:
	Global.has_key = true
	if Dialogic.current_timeline != null:
		return
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("inside_house01")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.pausing = true
	Global.emit_on_pause_mode()
	get_viewport().set_input_as_handled()

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	get_viewport().set_input_as_handled()
	Loader.chang_level("res://scenes/levels/landscape_4_night.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.pausing = false
	Global.emit_on_pause_mode()
