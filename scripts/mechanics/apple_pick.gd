extends Area3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@export var value: int = 20

func _on_body_entered(body):
	if body.is_in_group("Player") :
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("picked")
		Global.health += value
		Global.health = min(Global.health, 100)
		Global.emit_health_update()
