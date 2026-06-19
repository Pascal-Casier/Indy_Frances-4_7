extends Node

@export var ray : RayCast3D
@export var max_distance := 20.0  # Maximum grapple distance
@export var rest_length := 2.0    # How far to maintain from target point
@export var stiffness := 15.0     # Spring stiffness (higher = stronger pull) - Augmenté !
@export var damping := 1.0        # Damping to prevent oscillation
@export var rope : Node3D        # Visual representation of the rope
@export var reticle : Node        # Optional reticle to show when grapple is available

@onready var player : CharacterBody3D = get_parent()
var target : Vector3
var target_normal : Vector3      # Normal of the surface hit
var target_object               # The object we're grappling to
var launched := false
var can_grapple := true
var grapple_cooldown := 0.5      # Time before can grapple again

# Optional VFX/SFX
@export var grapple_sound : AudioStreamPlayer
@export var grapple_particles : GPUParticles3D

# Variables ajoutées pour améliorer le mouvement
var initial_jump_boost := 7.0  # Boost initial pour décoller
var applied_initial_boost := false

func _ready():
	if reticle:
		reticle.hide()

func _physics_process(delta: float) -> void:
	# Check if target is in range
	if ray.is_colliding():
		var hit_distance = ray.global_position.distance_to(ray.get_collision_point())
		if hit_distance <= max_distance:
			if reticle:
				reticle.show()
		else:
			if reticle:
				reticle.hide()
	else:
		if reticle:
			reticle.hide()
	
	# Handle input
	if Input.is_action_just_pressed("grapple") and can_grapple:
		launch()
	if Input.is_action_just_released("grapple"):
		retract()
	
	# Handle active grapple
	if launched:
		handle_grapple(delta)
	
	# Update visual rope
	update_rope()
	
func launch() -> void:
	if ray.is_colliding():
		var hit_distance = ray.global_position.distance_to(ray.get_collision_point())
		
		if hit_distance <= max_distance:
			target = ray.get_collision_point()
			target_normal = ray.get_collision_normal()
			target_object = ray.get_collider()
			launched = true
			applied_initial_boost = false
			
			# Play optional effects
			if grapple_sound:
				grapple_sound.play()
			if grapple_particles:
				grapple_particles.emitting = true
	
func retract() -> void:
	if launched:
		launched = false
		applied_initial_boost = false
		can_grapple = false
		
		# Start cooldown timer
		get_tree().create_timer(grapple_cooldown).timeout.connect(func(): can_grapple = true)
	
func handle_grapple(delta : float) -> void:
	# If the target no longer exists or has moved impossibly far, cancel grapple
	if target_object and !is_instance_valid(target_object):
		retract()
		return
	
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	# Apply initial jump boost to help player "take off"
	if not applied_initial_boost and player.is_on_floor():
		player.velocity.y = initial_jump_boost
		applied_initial_boost = true
	
	# Apply spring force based on distance
	var displacement = target_dist - rest_length
	
	var force = Vector3.ZERO
	if displacement > 0:
		# Spring force pulling toward target
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		# Damping force to prevent oscillation
		var vel_dot = player.velocity.dot(target_dir)
		var damping_force = -damping * vel_dot * target_dir
		
		force = spring_force + damping_force
	
	# Apply the force to player velocity
	player.velocity += force * delta
	
	# NOUVEAU: Limiter la hauteur du joueur pour qu'il ne dépasse pas le point d'attache
	if player.global_position.y > target.y:
		# Si le joueur est plus haut que le point d'attache, réduire sa vitesse verticale
		player.velocity.y = min(player.velocity.y, 0)
		# Option plus stricte: fixer directement la position
		# player.global_position.y = target.y
	
	# Add some upward force to prevent hitting the ground
	if player.is_on_floor() and displacement > 2.0:
		player.velocity.y += jump_boost * delta
	
	# Allow player to continue controlling movement while grappling
	handle_player_input(delta)

# Allow some player control while grappling
var influence_factor := 0.5  # Augmenté pour plus de contrôle
var jump_boost := 8.0  # Augmenté pour plus de hauteur
func handle_player_input(delta):
	# Read input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var h_rot = player.get_node("camroot/h").global_transform.basis.get_euler().y
	
	# Apply minimal movement influence
	if input_dir.length() > 0:
		var move_dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, h_rot).normalized()
		player.velocity -= move_dir * influence_factor

func update_rope() -> void:
	if !rope:
		return
		
	if !launched:
		rope.hide()
		return
		
	rope.show()
	var player_pos = player.global_position
	var rope_start = player_pos + Vector3(0, 1, 0)  # Adjust based on player model
	
	# Look at target and scale rope length
	rope.look_at_from_position(rope_start, target, Vector3.UP)
	var dist = rope_start.distance_to(target)
	rope.scale = Vector3(1, 1, dist)

# Debug drawing
#func _draw_debug():
	#if launched:
		#DebugDraw.draw_line_3d(player.global_position, target, Color.GREEN)
		#DebugDraw.draw_sphere(target, 0.2, Color.RED)
