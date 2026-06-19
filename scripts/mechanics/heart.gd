extends Area3D

@export var value: int = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_body_entered(body):
	if body.is_in_group("Player") and Global.health < 100:
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("picked")
		Global.health += value
		Global.health = min(Global.health, 100)
		Global.emit_health_update()


func _on_audio_stream_player_finished():
	queue_free()
