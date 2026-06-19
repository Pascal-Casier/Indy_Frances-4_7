extends Node3D

@export var btn_number : int = 0
@export var deactivatable : bool = false
@onready var audio_stream_player = $AudioStreamPlayer
var active : bool = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player") and active:
		audio_stream_player.play()
		Global.emit_open_door_gate(btn_number)
		if deactivatable : 
			active = false
