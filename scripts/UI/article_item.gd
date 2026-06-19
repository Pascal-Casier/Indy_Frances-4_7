extends Node3D

@export var item_name : String = "item"
@export var answer : String = "LE"

@onready var labe_item: Label = $Control/ColorRect/LabeItem
@onready var grid_container: GridContainer = $Control/ColorRect/GridContainer
@onready var press_e_label_3d: Label3D = $PressELabel3D
@onready var control: Control = $Control


func _ready() -> void:
	labe_item.text = item_name
	for i in grid_container.get_children():
		i.pressed.connect(_on_button_pressed.bind(i))
		
func _on_button_pressed(button):
	check_answer(button)

func check_answer(a):
	if a.text == answer:
		a.self_modulate = Color(0, 1, 0, 1)
		await get_tree().create_timer(1).timeout
		control.hide()
	else:
		a.self_modulate = Color(1, 0, 0, 1)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_label_3d.visible:
		control.show()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_label_3d.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_label_3d.hide()
