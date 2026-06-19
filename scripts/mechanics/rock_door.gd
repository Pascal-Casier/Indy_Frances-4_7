extends Node3D

@export var door_number : int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open := false

func _ready() -> void:
	Global.open_door_gate.connect(open_big_gate)
	
func open_big_gate(nb):
	if door_number == nb and not open:
		animation_player.play("open")
		%AudioStreamPlayer.play()
		open = true
