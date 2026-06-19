extends Node3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var tween: Tween
var original_scale: Vector3
var animation_played: bool = false

func _ready():
	original_scale = scale

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player") and not animation_played:
		animation_played = true
		spring_bounce_effect()

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		animation_played = false
		return_to_normal_with_bounce()

func spring_bounce_effect():
	if tween:
		tween.kill()
	tween = create_tween()
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()
	# Animation de rebond une seule fois
	tween.tween_property(self, "scale", original_scale + Vector3(.4, -0.2, 0.3), 0.2)
	#tween.tween_property(self, "scale", Vector3(0.85, 1.25, 0.85), 0.12)
	#tween.tween_property(self, "scale", Vector3(1.15, 0.8, 1.15), 0.1)
	#tween.tween_property(self, "scale", Vector3(0.95, 1.08, 0.95), 0.08)
	#tween.tween_property(self, "scale", Vector3(1.05, 0.92, 1.05), 0.06)
	tween.tween_property(self, "scale", original_scale, 0.2)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

func return_to_normal_with_bounce():
	if tween:
		tween.kill()
	tween = create_tween()
	
	tween.tween_property(self, "scale", original_scale, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
