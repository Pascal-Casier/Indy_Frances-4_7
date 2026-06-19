extends Control

@onready var button: Button = %Button
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var texture_rect: TextureRect = %TextureRect
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const bgd_image = preload("res://assets/images/ui/old_book1.jpg")
const HOUSE_FOREST_0 = preload("res://assets/images/ui/indiana/house_forest1.png")
const INDY_FORET = preload("res://assets/images/ui/indiana/Indy foret.png")
var bgd_list := []
@export_multiline var paragraph1 : String = ""
@export_multiline var paragraph2 : String = ""
@export_multiline var paragraph3 : String = ""
@export var audios : Array[AudioStream]

#@export_multiline var pnj_dialogues : PackedStringArray

var index : int = 0
var list = []

func _ready() -> void:
	
	bgd_list.append(HOUSE_FOREST_0)
	bgd_list.append(INDY_FORET)
	bgd_list.append(INDY_FORET)
	list.append(paragraph1)
	list.append(paragraph2)
	list.append(paragraph3)
	%Label.text = list[0]
	audio_stream_player.stream = audios[index]
	audio_stream_player.play()
	
func _on_button_pressed() -> void:
	
	texture_rect.texture = bgd_list[index]
	if index == 1:
		%Button.text = " Commencer ! "
		%Button.icon = null
		animation_player.play("zoom")
	if index < 2:
		index += 1
		%Label.text = list[index]
		audio_stream_player.stream = audios[index]
		audio_stream_player.play()
	else:
		animation_player.play("fade_out")
		await animation_player.animation_finished
		Loader.chang_level("res://scenes/levels/papys_house.tscn")
