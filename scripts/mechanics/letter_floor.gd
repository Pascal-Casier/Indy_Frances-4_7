extends Node3D

@export var lettre : String
@export var explode : bool = false
@export var hurting : bool = false
@onready var letter: Label3D = %letter

@onready var sparks: GPUParticles3D = %sparks
@onready var flash: GPUParticles3D = %flash
@onready var fire: GPUParticles3D = %fire
@onready var smoke: GPUParticles3D = %smoke

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var timer: Timer = %Timer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var contour: MeshInstance3D = $floor_tile_small/contour

@onready var material: MeshInstance3D = %Cube_002_Material_002_0

func _ready() -> void:
	animation_player.speed_scale = randf() + 0.6
	letter.text = lettre
	if explode:
		%Collision.set_deferred("disabled", true)
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and explode:
		
		sparks.emitting = true
		flash.emitting = true
		fire.emitting = true
		smoke.emitting = true
		audio_stream_player.play()
		%floor_tile_small.hide()
		%CollisionShape3D.set_deferred("disabled", true)
		timer.start()
		var mat := material.get_active_material(0).duplicate()
		if mat is StandardMaterial3D:
			mat.albedo_color = Color(0, 0, 0)  # vert
			material.set_surface_override_material(0, mat)
		if hurting:
			body.damage_received()
	
	elif body.is_in_group("Player") and not explode:
		contour.show()
		var mat := material.get_active_material(0).duplicate()
		if mat is StandardMaterial3D:
			mat.albedo_color = Color(0, 1, 0)  # vert
			material.set_surface_override_material(0, mat)
		%AudioStreamCorrect.play()


func _on_timer_timeout() -> void:
	%floor_tile_small.show()
	%CollisionShape3D.set_deferred("disabled", false)
	var mat := material.get_active_material(0).duplicate()
	if mat is StandardMaterial3D:
		mat.albedo_color = Color(0, 0, 0)  # vert
		material.set_surface_override_material(0, mat)
