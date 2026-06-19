extends StaticBody3D

@export_multiline var texte : String = ""
@export var audio : AudioStream

@onready var rich_text_label: RichTextLabel = $Control/bgd/MarginContainer/feuille/MarginContainer/ScrollContainer/RichTextLabel
@onready var audio_stream_voice: AudioStreamPlayer = $AudioStreamVoice
@onready var press_e: Sprite3D = $pressE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var control: Control = $Control


func _ready() -> void:
	rich_text_label.text = texte
	audio_stream_voice.stream = audio



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and press_e.visible:
		animation_player.play("open")
		await animation_player.animation_finished
		control.show()
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		audio_stream_voice.play()
		


func _on_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	control.hide()
	animation_player.play_backwards("open")
