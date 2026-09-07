extends Area3D

@onready var control: Control = $Control
@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var audio_stream_player_2: AudioStreamPlayer = $AudioStreamPlayer2


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().paused = true
		control.show()
		animation_player.play("fade_in")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$AudioStreamPlayer.play()


func _on_button_continuer_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().paused = false
	Loader.chang_level("res://scenes/levels/2.tscn")
	
