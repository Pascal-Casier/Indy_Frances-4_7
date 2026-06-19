extends RigidBody3D


var speed = 2000.0
var lifetime = 3.0

@onready var sparks: GPUParticles3D = $explosion/sparks
@onready var flash: GPUParticles3D = $explosion/flash
@onready var fire: GPUParticles3D = $explosion/fire
@onready var smoke: GPUParticles3D = $explosion/smoke
@onready var gpu_particles_3d: GPUParticles3D = $explosion/GPUParticles3D
@onready var skeleton_arrow: MeshInstance3D = $Skeleton_Arrow


func _ready():
	#apply_central_force(global_transform.basis.z * speed)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
		explode()
	elif body.is_in_group("Enemy"):
		body.hit(20)
		explode()

func explode():
	skeleton_arrow.hide()
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
	gpu_particles_3d.emitting = true
