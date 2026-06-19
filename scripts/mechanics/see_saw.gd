extends RigidBody3D

@export var tilt_damping: float = 5.0  # Amortissement

func _integrate_forces(state: PhysicsDirectBodyState3D):
	# Amortit le retour à l'équilibre
	angular_velocity.x = move_toward(angular_velocity.x, 0.0, tilt_damping * state.step)
