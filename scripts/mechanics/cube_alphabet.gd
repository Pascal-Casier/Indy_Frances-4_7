extends StaticBody3D

@onready var labels = $Cube_Default/labels
@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player = $AnimationPlayer
@onready var lbl_phonetic = $lblPhonetic

@export var letter : String = "A"
@export var phonetic : String = "[A]"
@export var letter_audio : AudioStream
@export var hidden : bool = false
@onready var audio_stream_showing: AudioStreamPlayer = $AudioStreamShowing


func _ready():
	if hidden:
		hide()
		%CollisionShape3D1.disabled = true
		%CollisionShape3D.disabled = true
	Global.letter_picked_up.connect(_on_letter_picked)
	audio_stream_player.stream = letter_audio
	lbl_phonetic.text = phonetic
	for l in labels.get_children():
		l.text = letter


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		animation_player.play("entered")
		audio_stream_player.play()
		lbl_phonetic.show()
		


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		lbl_phonetic.hide()

func _on_letter_picked(_letter:String) -> void:
	if letter.to_upper() == _letter.to_upper():
		show()
		%CollisionShape3D1.disabled = false
		%CollisionShape3D.disabled = false
		audio_stream_showing.play()
