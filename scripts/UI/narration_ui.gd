extends CanvasLayer

@export_multiline var lines : PackedStringArray
@export var audio_lines : Array[AudioStream]
@onready var rich_text_label: RichTextLabel = $Control/Bgrd/VBoxContainer/TextureRect/RichTextLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fx_player: AudioStreamPlayer = $AudioStreamPlayerFX
@onready var button_continue: Button = $Control/Bgrd/ButtonContinue

var index := 0

func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	rich_text_label.text = lines[index]
	audio_stream_player.stream = audio_lines[index]
	audio_stream_player.play()

func _on_button_previous_pressed() -> void:
	if index > 0:
		fx_player.play()
		index -= 1
		rich_text_label.text = lines[index]
		audio_stream_player.stream = audio_lines[index]
		audio_stream_player.play()

func _on_button_next_pressed() -> void:
	if index < lines.size() -1:
		fx_player.play()
		index += 1
		rich_text_label.text = lines[index]
		audio_stream_player.stream = audio_lines[index]
		audio_stream_player.play()
	if index == lines.size() -1:
		$Control/Bgrd/ButtonContinue.disabled = false
		pulse_btn()


func _on_button_continue_pressed() -> void:
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("fadeout")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	
	if _anim_name == "fadeout":
		get_tree().paused = false
		Loader.chang_level("res://scenes/levels/1.tscn")
		#queue_free()

func pulse_btn() -> void:
	var tween = create_tween()
	tween.set_loops() # Animation infinie
	# Animation de respiration avec scale
	tween.tween_property(button_continue, "scale", Vector2(1.1, 1.1), 0.7)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button_continue, "scale", Vector2(1.0, 1.0), 0.7)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
