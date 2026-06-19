extends Node3D

@export var sensibilite := 15.0
@export var vitesse_retour := 3.0
@export var vitesse_basculement := 5.0
@export var facteur_masse := 0.5
@export var masse_joueur := 70.0
@export var inertie := 2.0  # Résistance au changement de rotation

@onready var pivot = $Pivot
@onready var zone_detection = $Pivot/ZoneDetection

var joueur_dessus := false
var objets_sur_plateforme := []
var velocite_angulaire := 0.0

func _ready():
	zone_detection.body_entered.connect(_sur_corps_entre)
	zone_detection.body_exited.connect(_sur_corps_sorti)

func _sur_corps_entre(body):
	if body.is_in_group("Player"):
		joueur_dessus = true
	elif body is RigidBody3D:
		if body not in objets_sur_plateforme:
			objets_sur_plateforme.append(body)

func _sur_corps_sorti(body):
	if body.is_in_group("Player"):
		joueur_dessus = false
	elif body is RigidBody3D:
		objets_sur_plateforme.erase(body)

func _physics_process(delta):
	var couple_total := 0.0
	
	# Influence du joueur
	if joueur_dessus:
		var joueur = get_tree().get_first_node_in_group("Player")
		if joueur:
			var pos_joueur = pivot.to_local(joueur.global_position)
			couple_total += pos_joueur.x * masse_joueur * facteur_masse
	
	# Influence des objets
	for objet in objets_sur_plateforme:
		if objet == null:
			continue
		var pos_objet = pivot.to_local(objet.global_position)
		couple_total += pos_objet.x * objet.mass * facteur_masse
	
	# Physique avec inertie
	var acceleration = couple_total / inertie
	velocite_angulaire += acceleration * delta
	
	# Amortissement (friction)
	velocite_angulaire *= (1.0 - vitesse_basculement * delta)
	
	# Retour vers l'horizontal si rien dessus
	if not joueur_dessus and objets_sur_plateforme.size() == 0:
		var diff = -pivot.rotation.z
		velocite_angulaire += diff * vitesse_retour * delta
	
	# Appliquer la rotation
	pivot.rotation.z -= velocite_angulaire * delta
	
	# Limiter l'angle
	pivot.rotation.z = clamp(
		pivot.rotation.z,
		deg_to_rad(-sensibilite),
		deg_to_rad(sensibilite)
	)
