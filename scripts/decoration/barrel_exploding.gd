extends RigidBody3D

func destroy(nbr:int) ->void:
	apply_central_impulse(Vector3(0,200,0))
	await get_tree().get_frame()
	queue_free()
