extends Control
class_name  HotKeyRebindButton

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button

@export var action_name : String = "left"

func _ready() -> void:
	set_process_unhandled_input(false)
	set_action_name()
	set_text_for_key()
	
func set_action_name() -> void:
	label.text = "Unassigned"
	match action_name:
		"left":
			label.text = "Move Left"
		"right":
			label.text = "Move Right"
		"jump":
			label.text = "Jump"
		"forward":
			label.text = "Up"
		"backward":
			label.text = "Down"
		"sprint":
			label.text = "Sprint"
		"jump":
			label.text = "Jump"
		"aim":
			label.text = "Aim"
		"fire":
			label.text = "Fire"
		"interact":
			label.text = "Interact"
		"toggle_sprint":
			label.text = "Toggle sprint On/Off"

#func set_text_for_key() -> void:
	#var action_events = InputMap.action_get_events(action_name)
	#var action_event = action_events[0]
	#var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	#
	#button.text = "%s" % action_keycode
	
func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	if action_event is InputEventKey:
		var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
		button.text = "%s" % action_keycode
	elif action_event is InputEventMouseButton:
		@warning_ignore("unused_variable")
		var action_keycode = OS.get_keycode_string(action_event.button_index)
		button.text = "%s" % "Mouse Button " + str(action_event.button_index)

func _on_button_toggled(button_pressed):
	if button_pressed:
		button.text = "Press any key..."
		set_process_unhandled_key_input(button_pressed)
		
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		set_text_for_key()

func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false
	
func rebind_action_key(event) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
	
	
	
	
	
