extends AnimatableBody3D

@export var platform_id: int = 0
@export var down_offset: Vector3 = Vector3(0, -5, 0)
@export var move_duration: float = 2.0
@export var wait_duration: float = 5.0      # ← celle que tu voulais exporter
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var initial_position: Vector3
var is_moving: bool = false

@onready var timer: Timer = Timer.new()

func _ready():
	initial_position = global_position   # ← global car on bouge souvent en global
	add_child(timer)
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
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)     # optionnel – plus doux
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", initial_position + down_offset, move_duration)
	play_sound()
	tween.tween_callback(start_wait)

func start_wait():
	timer.start(wait_duration)

func _on_wait_timeout():
	ascend()

func ascend():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", initial_position, move_duration)
	play_sound()
	tween.tween_callback(func(): is_moving = false)

func play_sound() -> void:
	audio_stream_player_3d.play()
