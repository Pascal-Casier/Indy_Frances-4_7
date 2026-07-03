extends Area3D

@export var blow_force : int = 2
@onready var destruction: Destruction = %destruction
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func destroy(force = blow_force):
	destruction.destroy(force)

func hit(_force):
	audio_stream_player_3d.play()
	destroy(blow_force)
