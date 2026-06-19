extends Node3D

@export var door_nbr: int = 0
@export var already_opened : bool = false
@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer
var is_open := false

func _ready():
	Global.open_door_gate.connect(open_door)
	if already_opened :
		animation_player.play("open")


func open_door(nbr):
	if nbr == door_nbr and !is_open:
		if !already_opened:
			animation_player.play("open")
			audio_stream_player.play()
			is_open = true
		else:
			animation_player.play_backwards("open")
			audio_stream_player.play()
			is_open = false
	
		
