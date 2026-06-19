extends Area3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var book_page: Control = $Control
@onready var audio_stream_player_story: AudioStreamPlayer = $AudioStreamPlayerStory
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().paused = true
		book_page.show()
		audio_stream_player.play()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().create_timer(3.0).timeout
		audio_stream_player_story.play()
		await get_tree().create_timer(20.0).timeout
		$Control/book_page/TextureRect/Button.disabled = false

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.niveau_number = 2
	Loader.chang_level("res://scenes/levels/2.tscn")
	
