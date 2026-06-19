extends Node

@export var ray : RayCast3D
@export var max_distance := 20.0  # Maximum grapple distance
@export var rope_length := 0.0    # Distance entre le joueur et le point d'attache (calculée au lancement)
@export var swing_force := 20.0   # Force de balancement
@export var rope : Node3D        # Visual representation of the rope
@export var reticle : Node        # Optional reticle to show when grapple is available
@export var release_forward_boost := 8.0  # Force du boost vers l'avant au relâchement
@export var release_upward_boost := 5.0   # Force du boost vers le haut au relâchement
@export var momentum_preservation := 0.9  # Pourcentage de l'élan conservé (0.0 à 1.0)
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

# Variables pour le contrôle du mouvement
var initial_jump_boost := 7.0  # Boost initial pour décoller
var applied_initial_boost := false
var forward_momentum := 15.0  # Force vers l'avant lors du lancement du grappin

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
		handle_whip_physics(delta)
	
	# Update visual rope
	update_rope()
	
func launch() -> void:
	if ray.is_colliding():
		var hit_distance = ray.global_position.distance_to(ray.get_collision_point())
		
		if hit_distance <= max_distance:
			target = ray.get_collision_point()
			target_normal = ray.get_collision_normal()
			target_object = ray.get_collider()
			rope_length = hit_distance + 0.5  # Légère marge pour éviter les collisions
			launched = true
			applied_initial_boost = false
			
			# Donner un élan initial dans la direction regardée
			#var h_rot = player.get_node("camroot/h").global_transform.basis.get_euler().y
			#var forward_dir = -Vector3(sin(h_rot), 0, cos(h_rot))
			#player.velocity += forward_dir * forward_momentum
			
			# Boost vertical initial
			if player.is_on_floor():
				player.velocity.y = initial_jump_boost
				applied_initial_boost = true
			
			# Play optional effects
			if grapple_sound:
				grapple_sound.play()
			if grapple_particles:
				grapple_particles.emitting = true

func retract() -> void:
	if launched:
		# Sauvegarder la vitesse actuelle avant de la modifier
		var _current_velocity = player.velocity
		
		# Conserver l'élan (momentum) existant
		# Vous pouvez ajuster ce multiplicateur selon vos préférences
		player.velocity *= momentum_preservation
		
		# Déclencher un saut en utilisant la logique existante du joueur
		player.vertical_velocity = player.jump_magnitude
		player.jumping = true
		player.jump_number = 1
		player.animation_tree["parameters/jump_transition/transition_request"] = "jumping"
		player.animation_tree["parameters/JumpStateMachine/playback"].travel("Jump_Start")
		
		# Optionnel : Ajouter un boost horizontal dans la direction regardée
		var h_rot = player.get_node("camroot/h").global_transform.basis.get_euler().y
		var forward_dir = -Vector3(sin(h_rot), 0, cos(h_rot)).normalized()
		player.velocity += forward_dir * release_forward_boost
		
		## NOUVEAU: Ajouter un petit boost dans la direction regardée
		#var h_rot = player.get_node("camroot/h").global_transform.basis.get_euler().y
		#var forward_dir = -Vector3(sin(h_rot), 0, cos(h_rot))
		#player.velocity += forward_dir * release_forward_boost  # Force du boost au relâchement
		
		# NOUVEAU: Option - ajouter un léger boost vertical
		#player.velocity.y += release_upward_boost  # Petit saut au relâchement
		
		# NOUVEAU: Jouer un son de relâchement si disponible
		if grapple_sound:  # Vous pourriez avoir un son dédié pour le relâchement
			grapple_sound.pitch_scale = 1.2  # Son légèrement plus aigu pour différencier
			grapple_sound.play()
		
		# NOUVEAU: Créer des particules au point de relâchement
		if grapple_particles:
			grapple_particles.emitting = true
			# Arrêter l'émission après un court délai
			await get_tree().create_timer(0.2).timeout
			grapple_particles.emitting = false
		
		# NOUVEAU: Déclencher une animation spécifique sur le joueur
		# Si vous avez une animation de relâchement du fouet
		#if player.animation_tree:
			#player.animation_tree["parameters/grapple_release/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		
		player.is_releasing_grapple = true
		# Réinitialiser les variables du grappin
		launched = false
		applied_initial_boost = false
		can_grapple = false
		
		# NOUVEAU: Émettre un signal que d'autres systèmes peuvent écouter
		#emit_signal("grapple_released", player.global_position)
		
		# Ajouter un délai avant de pouvoir réutiliser le grappin
		get_tree().create_timer(grapple_cooldown).timeout.connect(func(): can_grapple = true)


#func retract() -> void:
	#if launched:
		#launched = false
		#applied_initial_boost = false
		#can_grapple = false
		#
		## Préserver une partie de l'élan
		#player.velocity *= 0.8
		#
		## Start cooldown timer
		#get_tree().create_timer(grapple_cooldown).timeout.connect(func(): can_grapple = true)

func handle_whip_physics(delta : float) -> void:
	# Si la cible n'existe plus, annuler le grappin
	if target_object and !is_instance_valid(target_object):
		retract()
		return
	
	# Distance actuelle entre le joueur et le point d'attache
	var to_target = target - player.global_position
	var current_distance = to_target.length()
	
	# Direction normalisée vers le point d'attache
	var direction_to_target = to_target.normalized()
	
	# --- PHYSIQUE DU PENDULE / FOUET ---
	
	# 1. Contrainte de longueur (empêche d'aller plus loin que la longueur du fouet)
	if current_distance > rope_length:
		# Repositionner le joueur à la longueur maximale du fouet
		var overshoot = current_distance - rope_length
		var correction = direction_to_target * overshoot
		
		# Appliquer la correction à la position (de manière progressive pour éviter les saccades)
		player.global_position += correction * 0.8
		
		# Projeter la vitesse le long de la surface du pendule
		var velocity_along_rope = player.velocity.project(direction_to_target)
		var velocity_perpendicular = player.velocity - velocity_along_rope
		
		# La composante de vitesse qui irait au-delà de la longueur de la corde est annulée
		if player.velocity.dot(direction_to_target) > 0:
			player.velocity -= velocity_along_rope
			
		# Conservation du mouvement perpendiculaire (effet de pendule)
		player.velocity = velocity_perpendicular * 0.98  # Légère friction pour éviter l'accélération infinie
	
	# 2. Appliquer une gravité modifiée pour créer l'effet pendulaire
	var gravity_strength = 28.0  # Même valeur que dans votre script de joueur
	
	# La gravité agit normalement
	player.velocity.y -= gravity_strength * delta
	
	# 3. Permettre au joueur d'influencer légèrement la trajectoire
	handle_player_input(delta)

# Permettre au joueur de contrôler légèrement sa trajectoire pendant le balancement
#Pour un style Indiana Jones réaliste: Utilisez une valeur entre 0.4 et 0.8. Cela donne un bon équilibre entre le réalisme du balancement et le contrôle.
#Pour un gameplay plus accessible: Augmentez à 1.0-1.2 pour donner plus de contrôle au joueur.
#Pour un défi plus difficile: Réduisez à 0.2-0.3 pour obliger le joueur à bien planifier ses balancements.
var influence_factor := 0.4
func handle_player_input(_delta):
	# Lire les entrées
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var h_rot = player.get_node("camroot/h").global_transform.basis.get_euler().y
	
	if input_dir.length() > 0:
		var move_dir = Vector3(-input_dir.x, 0, -input_dir.y).rotated(Vector3.UP, h_rot).normalized()
		
		# Appliquer une force d'influence, plus faible que le contrôle normal
		var influence = move_dir * influence_factor
		player.velocity += influence
		
		# Option: Permettre un saut pendant le balancement pour se détacher
		if Input.is_action_just_pressed("jump"):
			retract()
			player.velocity.y = player.jump_magnitude  # Utiliser la valeur de saut du joueur

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
