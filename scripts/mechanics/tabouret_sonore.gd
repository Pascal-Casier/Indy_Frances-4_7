extends Node3D

@export var son : AudioStream
@onready var press_e: Label3D = %pressE
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	audio_stream_player.stream = son

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible:
		audio_stream_player.play()
		animation_player.play("on")
