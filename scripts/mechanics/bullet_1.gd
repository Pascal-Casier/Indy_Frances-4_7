class_name Bullet
extends Node3D

const SPEED := 40.0
const ROTATION_SPEED : = 200.0

@onready var mesh_instance_3d = $MeshInstance3D
@onready var ray_cast_3d = $MeshInstance3D/RayCast3D
@onready var gpu_particles_3d = $GPUParticles3D

@onready var sparks = $explosion/sparks
@onready var flash = $explosion/flash
@onready var fire = $explosion/fire
@onready var smoke = $explosion/smoke
@onready var audio_stream_player = $AudioStreamPlayer


func _process(delta):
	position += transform.basis * Vector3(0,0,SPEED) * delta
	mesh_instance_3d.rotation_degrees.x += ROTATION_SPEED * delta
	if ray_cast_3d.is_colliding():
		audio_stream_player.play()
		ray_cast_3d.enabled = false
		mesh_instance_3d.hide()
		gpu_particles_3d.emitting = true
		sparks.emitting = true
		flash.emitting = true
		fire.emitting = true
		smoke.emitting = true
		if ray_cast_3d.get_collider().is_in_group("Enemy"):
			ray_cast_3d.get_collider().hit(26)
		elif ray_cast_3d.get_collider().is_in_group("Wall"):
			ray_cast_3d.get_collider().destroy(3)
		elif ray_cast_3d.get_collider().is_in_group("Target"):
			ray_cast_3d.get_collider().emit_hit_signal()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		

func _on_timer_timeout():
	queue_free()
