extends Node3D
class_name ExplosionFX

@onready var sparkles: GPUParticles3D = $sparkles
@onready var explosion: GPUParticles3D = $explosion
@onready var smoke: GPUParticles3D = $smoke
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func explode() -> void:
	sparkles.emitting = true
	explosion.emitting = true
	smoke.emitting = true
	audio_stream_player_3d.play()
