extends Node3D

@onready var area_3d: Area3D = %Area3D
@export var mesh_instance: MeshInstance3D  # Assignez votre mesh ici

@export_group("Physics")
@export var speed: float = 5.0
@export var direction: Vector3 = Vector3.BACK

@export_group("Shader")
@export var shader_speed_multiplier: float = 1.0:
	set(value):
		shader_speed_multiplier = value
		_update_shader()

@export var shader_scroll_direction: Vector2 = Vector2(0.0, -1.0):
	set(value):
		shader_scroll_direction = value
		_update_shader()

func _ready():
	_update_shader()

func _physics_process(_delta):
	for body in area_3d.get_overlapping_bodies():
		if body is CharacterBody3D:
			var velocity = body.velocity
			velocity += direction * speed
			body.velocity = velocity
			body.move_and_slide()

func _update_shader():
	if not mesh_instance:
		return
	
	var material = mesh_instance.get_active_material(0)
	if material and material is ShaderMaterial:
		material.set_shader_parameter("speed_multiplier", shader_speed_multiplier)
		material.set_shader_parameter("scroll_speed", shader_scroll_direction)
