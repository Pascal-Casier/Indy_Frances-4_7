extends Node3D

@export var automatic_start : bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	if automatic_start:
		animation_player.play("ArmatureAction")
		#audio_stream_player_3d.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()

func start_animation():
	animation_player.play("ArmatureAction")
