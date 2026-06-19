extends Node3D

@onready var animation: AnimationPlayer = %AnimationPlayer


func _on_book_interactable_pressed_e() -> void:
	animation.play("slide")
