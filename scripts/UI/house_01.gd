extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and %Label3D.visible:
		%AudioDoor.play()
		%AnimationPlayer.play("fadeout")
		
func _on_audio_door_finished() -> void:
	#SceneLoader.load_scene("res://scenes/levels/level_01.tscn")
	Loader.chang_level("res://scenes/levels/maison_vovo.tscn")
