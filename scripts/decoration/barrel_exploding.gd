extends RigidBody3D

@onready var explosion_fx: Node3D = $explosionFX
@onready var exploding_barrel: MeshInstance3D = $ExplodingBarrel
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


func destroy(_nbr:int) ->void:
	apply_central_impulse(Vector3(0,200,0))
	await get_tree().get_frame()
	queue_free()

func hit(_nb:int) -> void:
	exploding_barrel.hide()
	collision_shape_3d.set_deferred("disabled", true)
	explosion_fx.explode()
	await get_tree().create_timer(1).timeout
	queue_free()
	
