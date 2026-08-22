extends Node3D

@export var platform_id: int = 0
@export var is_staying_in_place : bool = false
@export var wait_duration: float = 5.0      # ← celle que tu voulais exporter
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var timer: Timer = $Timer
@onready var pivot: Node3D = $pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_moving: bool = false

func _ready():
	timer.one_shot = true
	timer.timeout.connect(_on_wait_timeout)
	
	Global.open_door_gate.connect(_on_activate)

func _on_activate(received_id: int):
	if received_id != platform_id:
		return
	if is_moving:
		return
	is_moving = true
	descend()

func descend():
	animation_player.play("flip")
	if !is_staying_in_place:
		start_wait()

func start_wait():
	timer.start(wait_duration)

func _on_wait_timeout():
	ascend()
	
func ascend():
	animation_player.play("down")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "down":
		is_moving = false
