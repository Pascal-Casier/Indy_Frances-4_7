extends RayCast3D

@onready var beam_mesh: MeshInstance3D = $BeamMesh
@onready var end_particles: GPUParticles3D = $endParticles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var cast_point
	force_raycast_update()
	if is_colliding():
		cast_point = to_local(get_collision_point())
		beam_mesh.mesh.height = cast_point.y
		beam_mesh.position.y = cast_point.y/2
		end_particles.position.y = cast_point.y
		if get_collider().is_in_group("Player"):
			get_collider().damage_received()
