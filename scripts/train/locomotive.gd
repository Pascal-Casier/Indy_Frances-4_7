extends Node3D

@onready var lbl_press_e: Node3D = %lblPressE
@export var next_level_string : String = "res://scenes/train/train1.tscn"


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") :
		lbl_press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") :
		lbl_press_e.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and lbl_press_e.visible:
		Loader.chang_level(next_level_string)
