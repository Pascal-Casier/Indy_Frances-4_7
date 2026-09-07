extends Control

@export var pausing : bool = false
@export_multiline var mon_text : String = "test"
@export var audio : AudioStream
@onready var rich_text_label: RichTextLabel = $TextureRect/MarginContainer/RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var player : CharacterBody3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if pausing : get_tree().paused = true
	rich_text_label.text = mon_text
	animation_player.play("fade_in")
	if audio:
		audio_stream_player.stream = audio
		await get_tree().create_timer(2.0).timeout
		audio_stream_player.play()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		_on_button_continuer_pressed()


func _on_button_continuer_pressed() -> void:
	get_viewport().set_input_as_handled()
	audio_stream_player.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	if pausing:
		get_tree().paused = false
	if player:
		player.can_move = true
	queue_free()
