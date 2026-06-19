extends CharacterBody3D

# Groupe d'export pour les paramètres de mouvement dans l'éditeur
@export_group("Movement")
@export var move_speed := 6.0
@export var run_speed := 11.0			# Vitesse de déplacement de base
@export var acceleration := 20.0		# Accélération pour atteindre la vitesse max
@export var rotation_speed := 12.0		# Vitesse de rotation du personnage
@export var jump_impulse := 12.0		# Force de saut

# Références aux nodes enfants
@onready var _camera: Camera3D = $SpringArmPivot/Camera3D			# Référence à la caméra
@onready var indiana_mesh: Node3D = %Indiana_animated				# Référence au mesh du personnage
@onready var animation_tree: AnimationTree = %AnimationTree		# Référence à l'arbre d'animation

######## animation temp ##########
@onready var animation_player: AnimationPlayer = $Indiana_animated/AnimationPlayer	# Référence à l'animation player (temporaire)

# Variables d'état
var _last_movement_direction := Vector3.BACK	# Dernière direction de mouvement
var _gravity := -30.0							# Force de gravité appliquée
var blend_value := 0.0							# Valeur de blend pour les animations

func _physics_process(delta: float) -> void:
	# Récupération de l'input brut du joueur
	var raw_input := Input.get_vector("left", "right", "forward", "back")
	
	# Calcul de la direction de mouvement relative à la caméra
	var forward := _camera.global_basis.z	# Avant selon la caméra
	var right := _camera.global_basis.x		# Droite selon la caméra
	var move_direction := forward * raw_input.y + right * raw_input.x
	
	# Normalisation du mouvement
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	# Gestion de la vélocité verticale
	var y_velocity := velocity.y
	velocity.y = 0	# On ignore temporairement Y
	
	# Application du mouvement horizontal
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	
	# Réapplication de la vélocité verticale
	velocity.y = y_velocity + _gravity * delta
	
	# Gestion du saut
	var _is_starting_jump := Input.is_action_just_pressed("jump") and is_on_floor()
	if _is_starting_jump:
		velocity.y += jump_impulse
	
	# Application du mouvement
	move_and_slide()
	
	# Rotation du personnage
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	indiana_mesh.global_rotation.y = lerp_angle(indiana_mesh.rotation.y, target_angle, rotation_speed * delta)
	
	# Gestion des animations
	if _is_starting_jump:
		animation_tree.set("parameters/jump_state/blend_amount", 0.0)
		animation_tree.set("parameters/stand/blend_amount", 1.0)
		
	elif not is_on_floor() and velocity.y < 0:
		animation_tree.set("parameters/jump_state/blend_amount", 1.0)
		
	elif is_on_floor():
		var ground_speed := velocity.length()
		
		if ground_speed > 0.0:
			blend_value = lerp(blend_value, 0.0, 0.1)
			animation_tree.set("parameters/stand/blend_amount", blend_value)
			
		else:
			blend_value = lerp(blend_value, -1.0, 0.1)
			animation_tree.set("parameters/stand/blend_amount", blend_value)
			
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint"):
		velocity
		
	
