extends Area3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var book_page: Control = $Intro_message_Livret
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $Intro_message_Livret/AnimationPlayer


func _ready() -> void:
	book_page.set_process(false)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().paused = true
		audio_player.play()
		book_page.show()
		animation_player.play("fade_in")
		book_page.set_process(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_intro_message_livret_exit() -> void:
	Loader.chang_level("res://scenes/levels/2.tscn")
