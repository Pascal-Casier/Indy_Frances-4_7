extends Control

func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if Global.mode == Global.GameMode.READING:
		return
	if get_tree().paused:
		return
	if event.is_action_pressed("inventory") and Global.mode == Global.GameMode.PLAY:
		if visible:
			hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
		else:
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true


func _on_exit_icon_pressed() -> void:
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
