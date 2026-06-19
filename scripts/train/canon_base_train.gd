extends MeshInstance3D

# Références aux nœuds enfants
@onready var tourelle_rotation = %Gun_3_Mid
@onready var canon_elevation = %Gun_3_Gun


# Limites de rotation (en degrés)
@export var rotation_horizontale_min: float = -180.0
@export var rotation_horizontale_max: float = 180.0
@export var rotation_verticale_min: float = -45.0
@export var rotation_verticale_max: float = 45.0
@export var bullet_speed: float = 25.0
#@export var min_bullet_speed: float = 5.0   # Vitesse minimum
#@export var max_bullet_speed: float = 50.0  # Vitesse maximum
#@export var speed_adjustment: float = 5.0   # Incrément de vitesse
@export var bullet_scene: PackedScene  # Glisse ton scène de balle ici

# Sensibilité de la souris
@export var sensibilite_souris: float = 0.5
@onready var firing_point = %Marker3D  # Position3D pour le point de tir
#@onready var hero_pos: Marker3D = %hero_pos
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

# Variables pour stocker la rotation actuelle
var rotation_horizontale: float = 0.0
var rotation_verticale: float = 0.0

var can_be_used := true
var can_fire := true
var player = null

#tween variables
var original_position: Vector3
var recoil_distance: float = 0.5  # Distance du recul en unités

func _ready():
	# Capturer la souris si nécessaire
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_position = canon_elevation.position
	

func _input(event):
	if event is InputEventMouseMotion and can_be_used:
		# Calculer le delta de mouvement de la souris
		var delta_horizontal = -event.relative.x * sensibilite_souris
		var delta_vertical = -event.relative.y * sensibilite_souris
		
		# Appliquer la rotation avec les limites
		rotation_horizontale += delta_horizontal
		rotation_verticale -= delta_vertical
		
		# Limiter les rotations
		rotation_horizontale = clamp(rotation_horizontale, 
			rotation_horizontale_min, rotation_horizontale_max)
		rotation_verticale = clamp(rotation_verticale, 
			rotation_verticale_min, rotation_verticale_max)
		
		# Appliquer les rotations aux nœuds
		# Rotation horizontale sur la tourelle (axe Y)
		tourelle_rotation.rotation_degrees.y = rotation_horizontale
		
		# Rotation verticale sur l'élévation du canon (axe X)
		canon_elevation.rotation_degrees.x = rotation_verticale
	
	if event.is_action_pressed("fire") and can_be_used and can_fire:
		fire()
	
	if event.is_action_pressed("ui_cancel"):
		can_be_used = false
		if player:
			player.can_move = true
			player = null
			%Camera3D.current = false
			
func _process(delta):
	# Optionnel : contrôles clavier pour affiner
	if Input.is_action_pressed("ui_left"):
		rotation_horizontale -= 30.0 * delta
	if Input.is_action_pressed("ui_right"):
		rotation_horizontale += 30.0 * delta
	if Input.is_action_pressed("ui_up"):
		rotation_verticale -= 30.0 * delta
	if Input.is_action_pressed("ui_down"):
		rotation_verticale += 30.0 * delta
	
	# Appliquer les limites
	rotation_horizontale = clamp(rotation_horizontale, 
		rotation_horizontale_min, rotation_horizontale_max)
	rotation_verticale = clamp(rotation_verticale, 
		rotation_verticale_min, rotation_verticale_max)
	
	# Mettre à jour les rotations
	tourelle_rotation.rotation_degrees.y = rotation_horizontale
	canon_elevation.rotation_degrees.x = rotation_verticale
	

# Fonction pour réinitialiser la position
func reset_position():
	rotation_horizontale = 0.0
	rotation_verticale = 0.0
	tourelle_rotation.rotation_degrees.y = 0.0
	canon_elevation.rotation_degrees.x = 0.0

# Fonction pour obtenir la direction de tir
func get_firing_direction() -> Vector3:
	return canon_elevation.global_transform.basis.z

func fire():
	if bullet_scene:
		# ajouter un effet de recul
		var tween = create_tween()
		tween.set_parallel(true)
	
	# Recul avec easing pour un effet plus naturel
		tween.tween_property(canon_elevation, "position", 
			original_position + transform.basis.z * recoil_distance, 
			0.08).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		# Retour avec un léger rebond
		tween.tween_property(canon_elevation, "position", original_position, 
			0.4).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Instancier la balle
		var bullet = bullet_scene.instantiate()
		
		# Positionner la balle au point de tir
		bullet.global_transform = firing_point.global_transform
		
		# Ajouter à la scène
		get_tree().root.add_child(bullet)
		
		# Appliquer une force (selon la direction du canon)
		if bullet is RigidBody3D:
			var direction = get_firing_direction()
			bullet.linear_velocity = direction * bullet_speed
		audio_stream_player.play()
		can_fire = false
		await get_tree().create_timer(0.5).timeout
		can_fire = true
		

		
		

#func _on_body_entered(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#player = body
		#var tween = create_tween()
		#tween.tween_property(body, "position", hero_pos.global_position , 0.5)
		#await tween.finished
		##await get_tree().create_timer(0.5).timeout
		#player.can_move = false
		#%Camera3D.current = true
		#can_be_used = true
		#%positionmark.hide()
		#%esc.show()
#
#func _on_body_exited(body: Node3D) -> void:
	#if body.is_in_group("Player"):
		#player = null
		#%positionmark.show()
		#%esc.hide()
