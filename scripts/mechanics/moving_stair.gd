extends Node3D

@export var door_nbr: int = 0

enum RotationDirection { RIGHT, LEFT }

@export var rotation_direction: RotationDirection = RotationDirection.RIGHT

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_rotated := false

func _ready():
	Global.open_door_gate.connect(_on_signal_triggered)

func _on_signal_triggered(number:int) -> void:
	if number == door_nbr:
		if !is_rotated:
			match rotation_direction:
				RotationDirection.RIGHT:
					animation_player.play("rotate_right")
				RotationDirection.LEFT:
					animation_player.play("rotate_left")
			is_rotated = true
		elif is_rotated:
			match rotation_direction:
				RotationDirection.RIGHT:
					animation_player.play_backwards("rotate_right")
				RotationDirection.LEFT:
					animation_player.play_backwards("rotate_left")
			is_rotated = false
