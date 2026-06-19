extends StaticBody3D

@export var title : String
@export var title_sound : AudioStream
@export var liste_words : Array[String]
@export var liste_sounds : Array[AudioStream]

@onready var prononce_text: Label3D = $Cube/PrononceText
@onready var press_elbl: Label3D = $"3D_button/PressE"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var index = 0

func _ready() -> void:
	$Cube/lblTitle.text = title
	prononce_text.text = liste_words[index]
	audio_stream_player.stream = liste_sounds[index]

func _process(_delta: float) -> void:
	if press_elbl.visible:
		if Input.is_action_just_pressed("interact"):
			audio_stream_player.stream = liste_sounds[index]
			modulate_text()
			audio_stream_player.play()
			$AnimationPlayer.play("click")
			$Timer.start()

func _on_Area_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		press_elbl.show()
		audio_stream_player.stream = title_sound
		audio_stream_player.play()

func _on_Area_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		press_elbl.hide()


func _on_Timer_timeout() -> void:
	if index < liste_words.size()-1:
		index +=1
	elif index == liste_words.size()-1:
		index = 0
	$AnimationPlayer.play("update_text")
	prononce_text.text = liste_words[index]
	audio_stream_player.stream = liste_sounds[index]

func modulate_text():
	var tween = create_tween()
	tween.tween_property(prononce_text, "modulate", Color.GREEN, 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(prononce_text, "modulate", Color.WHITE, 0.1)
	
