extends Node3D

@export var son : AudioStream
@export_multiline var text1 : String
@export_multiline var text2 : String
@onready var press_e: Label3D = $pressE
@onready var lesson: CanvasLayer = %Lesson
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var rich_text_label_2: RichTextLabel = %RichTextLabel2
@onready var button: Button = %Button

var player : CharacterBody3D = null

func _ready() -> void:
	press_e.hide()
	rich_text_label.text = text1
	rich_text_label_2.text = text2
	audio_stream_player.stream = son

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()
		player = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()
		if player:
			player.can_move = true
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible:
		if player :
			player.can_move = false
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			lesson.show()

func _on_button_audio_pressed() -> void:
	if audio_stream_player.playing:
		audio_stream_player.stop()
	else:
		audio_stream_player.play()

func _on_buttonexit_pressed() -> void:
	if player:
		player.can_move = true
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	lesson.hide()
