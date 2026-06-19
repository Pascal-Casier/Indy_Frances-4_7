extends Area3D

signal Epressed

@export_multiline var note_text : String
@export var discard : bool = false
@export var to_main_menu : bool = false

@onready var label_3d_press_e: Label3D = %Label3DPressE
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var control: Control = %Control

func _ready() -> void:
	rich_text_label.text = note_text

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d_press_e.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d_press_e.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and label_3d_press_e.visible:
		control.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = true
		Epressed.emit()

func _on_button_ok_pressed() -> void:
	control.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	if discard:
		queue_free()
	if to_main_menu:
		Loader.chang_level("res://scenes/UI/area_3d_interactor.tscn")
