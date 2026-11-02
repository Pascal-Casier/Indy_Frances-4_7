extends Node3D


@export var door_number : int = -1
@export var target_node : Node3D
@export var move_distance: float = 3.0
@export var move_time: float = 1.0
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var initial_y: float = 0.0
var is_moving: bool = false

func _ready() -> void:
	Global.open_door_gate.connect(open_door)
	
	

func open_door(nbr: int) -> void:
	if is_moving or door_number != nbr:
		return
	is_moving = true
	
	# Lance le son
	if audio_player.stream:
		audio_player.play()
	
	# Animation fluide avec le Tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target_node, "position:y", move_distance, move_time)
	
	await tween.finished
	
	audio_player.stop()
	is_moving = false
