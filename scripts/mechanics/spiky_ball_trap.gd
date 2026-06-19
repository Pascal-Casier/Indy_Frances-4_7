extends RigidBody3D

@onready var sparks: GPUParticles3D = $explosion/sparks
@onready var flash: GPUParticles3D = $explosion/flash
@onready var fire: GPUParticles3D = $explosion/fire
@onready var smoke: GPUParticles3D = $explosion/smoke
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var gpu_particles_3d: GPUParticles3D = $explosion/GPUParticles3D
@onready var spiky_ball: MeshInstance3D = $SpikyBall
@onready var area_3d: Area3D = $Area3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
		explode()
		
	await get_tree().create_timer(6.0).timeout
	explode()

func explode() -> void:
	spiky_ball.hide()
	area_3d.set_deferred("monitoring", false)
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
	audio_stream_player.play()
	await get_tree().create_timer(1.0).timeout
	queue_free()
