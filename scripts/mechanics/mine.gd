extends StaticBody3D

# Paramètres réglables dans l'inspecteur
@export var delai_explosion: float = 1.9 # Temps avant BOUM
@export var degats: int = 25
@export var rayon_detection: float = 2.0  # Zone de déclenchement
@export var rayon_explosion: float = 6.0

# Références aux nœuds
@onready var timer = %Timer
@onready var mesh = %MeshInstance
@onready var detection_zone = %ZoneDetection
@onready var zone_degats: Area3D = %zone_degats

@onready var audio = %AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var est_active = false
var a_explose = false

func _ready():
	# Configure le timer
	timer.wait_time = delai_explosion
	timer.one_shot = true
	# AJOUT : Ajuste la taille de la zone de détection
	var collision_shape = detection_zone.get_node("CollisionShape3D")
	if collision_shape and collision_shape.shape is SphereShape3D:
		collision_shape.shape.radius = rayon_detection
	var col_degats = zone_degats.get_node("CollisionShape3D")
	if col_degats.shape is SphereShape3D:
		col_degats.shape.radius = rayon_explosion
	
	# Connecter les signaux (ou fais-le via l'interface de Godot)
	detection_zone.body_entered.connect(_on_zone_detection_body_entered)
	timer.timeout.connect(_on_timer_timeout)

# 1. Le joueur approche
func _on_zone_detection_body_entered(body):
	if not est_active and not a_explose:
		if body.is_in_group("Player"): # Assure-toi que ton perso est dans le groupe "joueur"
			amorcer_mine()

# 2. La mine s'active (Bip Bip + Clignotement)
func amorcer_mine():
	est_active = true
	timer.start()
	animation_player.play("triggered")
	# Effet visuel : Clignotement rouge rapide (Tween)
	

# 3. BOUM !
func _on_timer_timeout():
	exploser()

func exploser():
	a_explose = true
	est_active = false
	
	for p in $explosion.get_children():
		if p is GPUParticles3D:
			p.emitting = true
	
	# 1. Visuel et Son
	mesh.visible = false # La mine disparait
	
	audio.play()
	
	# 2. Appliquer les dégâts
	# On vérifie qui est dans la zone AU MOMENT de l'explosion
	var corps_touches = zone_degats.get_overlapping_bodies()
	
	for corps in corps_touches:
		if corps.has_method("damage_received"):
			# Optionnel : Calculer la distance pour réduire les dégâts si on est loin
			var distance = global_position.distance_to(corps.global_position)
			if distance <= rayon_explosion:
				#corps.recevoir_degats(degats)
				corps.damage_received()
				

	# 3. Nettoyage
	# On attend que les particules finissent avant de supprimer l'objet
	await get_tree().create_timer(1.5).timeout
	queue_free()
