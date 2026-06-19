extends Area3D

var time = 2.0

func _process(delta):
	$"1H_Wand".rotation.y += delta * time
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.show_wand()
		$AudioStreamPlayer.play()
		$CollisionShape3D.disabled = true
		hide()
		

func _on_audio_stream_player_finished():
	queue_free()
