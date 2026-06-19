extends Control

signal success()

@export var phrase : String
@export var answer : String
@export var options : Array[String]
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var options_container: VBoxContainer = %OptionsContainer
var index := 0
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var hearts_container: HBoxContainer = %HeartsContainer


func _ready() -> void:
	rich_text_label.text = phrase
	for b in options_container.get_children():
		b.text = options[index]
		index += 1
		b.pressed.connect(_on_btn_pressed.bind(b.text))


func _on_btn_pressed(value : String):
	if value == answer:
		success.emit("yes")
		queue_free()
	else:
		audio_stream_player.play()
		var heart_to_pop = hearts_container.get_child(0)
		heart_to_pop.queue_free()
		success.emit("no")
