extends Control

@onready var label: Label = $MarginContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.wheels_nb_found.connect(_on_new_wheel_found)


func _on_new_wheel_found(wheel_nbr) -> void:
	label.text = str(wheel_nbr)
