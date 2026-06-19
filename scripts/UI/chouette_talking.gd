extends Area3D

@export var texte : String = "test"
@export var kill : bool = true
var player = null
@onready var label: Label = $Control/MarginContainer/HBoxContainer/NinePatchRect/MarginContainer/Label
@onready var control: Control = $Control


func _ready() -> void:
	label.text = texte


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		player.can_move = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		control.show()
		


func _on_button_exit_pressed() -> void:
	if player:
		player.can_move = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	control.hide()
	player = null
	if kill:
		queue_free()
	
