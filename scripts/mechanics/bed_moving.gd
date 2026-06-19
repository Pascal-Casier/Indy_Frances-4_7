extends Node3D

@export var door_nbr := 0
var is_open := false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Global.open_door_gate.connect(open_door)


func open_door(nbr):
	if nbr == door_nbr and !is_open:
		animation_player.play("move_left")
		is_open = true
		
func _on_book_interactable_pressed_e() -> void:
	open_door(door_nbr)
