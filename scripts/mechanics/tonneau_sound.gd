extends Node3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _on_tonneau_breakable_play_sound() -> void:
	audio_stream_player_3d.play()
