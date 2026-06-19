extends Area3D

signal play_sound

@export var blow_force : int = 2
@onready var destruction: Destruction = $Destruction


func destroy(force = blow_force):
	destruction.destroy(force)

func hit(_force):
	play_sound.emit()
	destroy(blow_force)
