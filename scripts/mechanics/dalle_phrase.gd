class_name Dalle_phrase
extends Area3D

signal text_emit(text: String)
@export var dalle_texte : String = "Test"
@export var is_talking : bool = false
@export var phrase_sound: AudioStream
@export var trigger : bool = false
@export var door_nbr : int = -1
@onready var text_lbl: Label3D = $dalle/textLbl
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dalle: MeshInstance3D = $dalle
@onready var audio_stream_talking: AudioStreamPlayer = $AudioStreamTalking

var pressed := false

func _ready() -> void:
	text_lbl.text = dalle_texte
	if phrase_sound:
		audio_stream_talking.stream = phrase_sound


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not pressed:
		animation_player.play("stepped_in")
		text_emit.emit(text_lbl.text)
		pressed = true
		if is_talking:
			await get_tree().create_timer(0.2).timeout
			audio_stream_talking.play()
			await audio_stream_talking.finished
			reset()
		if trigger:
			Global.emit_open_door_gate(door_nbr)
			trigger = false

func _on_body_exited(_body: Node3D) -> void:
	pass

func reset() -> void:
	if pressed:
		animation_player.play("stepped_out")
		pressed = false
