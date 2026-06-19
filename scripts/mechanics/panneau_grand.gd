extends Node3D

@onready var lbltext: Label3D = $Text
@onready var press_e: Label3D = $Button3D/PressE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pictures_frame: Sprite3D = %Picutres_frame
@onready var audio: AudioStreamPlayer = $Audio

@export var hints_list : Array[String]
@export var visual_tuto : bool = false
@export var pictures_list : Array[Texture2D]
@export var audio_list : Array[AudioStream]

var index := 0

func _ready() -> void:
	if !visual_tuto and !hints_list.is_empty():
		lbltext.text = hints_list[0]
		_play_audio(0)
	elif visual_tuto and !pictures_list.is_empty():
		pictures_frame.texture = pictures_list[index]
		pictures_frame.show()
		lbltext.hide()
		_play_audio(0)

func _process(_delta: float) -> void:
	if press_e.visible:
		if Input.is_action_just_pressed("interact"):
			animation_player.play("clic")
			if !visual_tuto and !hints_list.is_empty():
				index = (index + 1) % hints_list.size()
				lbltext.text = hints_list[index]
				_play_audio(index)
			elif visual_tuto and !pictures_list.is_empty():
				index = (index + 1) % pictures_list.size()
				pictures_frame.texture = pictures_list[index]
				_play_audio(index)
				
func _play_audio(audio_index: int) -> void:
	if !audio_list.is_empty() and audio_index < audio_list.size():
		if audio_list[audio_index] != null:
			audio.stream = audio_list[audio_index]
			audio.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()
