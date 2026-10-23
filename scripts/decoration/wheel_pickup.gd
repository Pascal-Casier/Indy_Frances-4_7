extends Area3D

@export var vitesse_rotation: float = 1.0  # en radians par seconde
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _process(delta: float) -> void:
	rotate_y(vitesse_rotation * delta)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		audio_stream_player.play()
		set_deferred("monitoring", false)
		Global.wheels_picked_up_nbr += 1
		await audio_stream_player.finished
		queue_free()
