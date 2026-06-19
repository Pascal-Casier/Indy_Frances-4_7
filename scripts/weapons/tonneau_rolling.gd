extends RigidBody3D

func _ready() -> void:
	var timer = get_tree().create_timer(10.0)
	timer.timeout.connect(die)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("damage_received"):
			body.damage_received()

func die():
	# Désactiver la physique pendant l'animation
	freeze = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)# petit "suck in" avant de disparaître
	tween.tween_callback(queue_free)
