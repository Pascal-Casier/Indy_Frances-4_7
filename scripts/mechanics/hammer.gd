extends Node3D

@onready var sparks: GPUParticles3D = %sparks
@onready var flash: GPUParticles3D = %flash
@onready var fire: GPUParticles3D = %fire
@onready var smoke: GPUParticles3D = %smoke


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	if body.is_in_group("voiture"):
		if body.get_parent().has_method("appliquer_penalite"):
				body.get_parent().appliquer_penalite(0.3, 3.0)

func sparking()-> void:
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
