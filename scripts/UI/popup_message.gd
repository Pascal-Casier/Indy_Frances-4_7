extends CanvasLayer

@export_multiline var mon_text : String
@export var audio_part : AudioStream
@onready var text_label: RichTextLabel = $TextureRect/MarginContainer/label
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button_ok: Button = $TextureRect/ButtonOK

var player = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.can_move = false
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	text_label.text = mon_text
	audio_stream_player.stream = audio_part

func _on_button_ok_pressed() -> void:
	animation_player.play("exit")
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().paused = false
	if player:
		player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()


func _on_button_audio_pressed() -> void:
	audio_stream_player.play()
	$TextureRect/ButtonAudio.disabled = true


func _on_audio_stream_player_finished() -> void:
	$TextureRect/ButtonAudio.disabled = false
