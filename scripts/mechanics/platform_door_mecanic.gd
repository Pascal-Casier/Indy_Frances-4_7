extends Node3D

@export var door_nbr : int = -1
@export var distance_to_go := Vector3(0,5,0)
@export var can_come_back : bool = false
@export var time_of_animation := 2.0
@onready var platform: MeshInstance3D = $platform
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var is_up := false

func _ready() -> void:
	Global.open_door_gate.connect(move)

func move(nbr) -> void:
	if nbr == door_nbr:
		if not is_up:
			var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(platform,"position", distance_to_go, time_of_animation)
			audio_stream_player.play()
			is_up = true
			#tween.kill()
		elif is_up and can_come_back:
			var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(platform,"position", Vector3.ZERO, time_of_animation)
			audio_stream_player.play()
			is_up = false
			#tween.kill()
