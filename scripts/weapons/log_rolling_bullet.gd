extends RigidBody3D



func die():
	# Désactiver la physique pendant l'animation
	freeze = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)# petit "suck in" avant de disparaître
	tween.tween_callback(queue_free)
