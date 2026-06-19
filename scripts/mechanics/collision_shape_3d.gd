extends StaticBody3D

## Configuration de la plateforme
@export_group("Mouvement")
@export var hauteur_max: float = 3.0  # Hauteur maximale de descente
@export var vitesse_montee: float = 2.0  # Vitesse de montée
@export var vitesse_descente: float = 3.0  # Vitesse de descente
@export var lissage: float = 5.0  # Plus c'est élevé, plus c'est réactif (2-10)

@export_group("Poids")
@export var poids_necessaire: float = 1.0  # Poids minimum pour descendre
@export var sensibilite: float = 1.0  # Multiplicateur de sensibilité au poids

@export_group("Animation")
@export var type_interpolation: TypeInterpolation = TypeInterpolation.SMOOTH
@export var durete_ressort: float = 8.0  # Pour le mode ressort (plus élevé = plus rigide)
@export var amortissement: float = 0.5  # Pour le mode ressort (0-1, plus élevé = moins de rebond)

enum TypeInterpolation {
	LINEAR,      # Mouvement linéaire simple
	SMOOTH,      # Interpolation douce (ease in/out)
	RESSORT,     # Simulation de ressort physique
	ELASTIQUE    # Effet élastique avec léger rebond
}

# Variables internes
var position_initiale: Vector3
var poids_actuel: float = 0.0
var objets_dessus: Array = []
var velocite_y: float = 0.0  # Pour la simulation physique

func _ready():
	position_initiale = global_position
	
	# Connecter le détecteur de zone
	if has_node("DetecteurZone"):
		var detecteur = $DetecteurZone
		detecteur.body_entered.connect(_on_body_entered)
		detecteur.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	# Calculer le poids total
	calculer_poids_total()
	
	# Déterminer la position cible
	var position_cible_y = position_initiale.y
	
	if poids_actuel >= poids_necessaire:
		var ratio_descente = min((poids_actuel / poids_necessaire) * sensibilite, 1.0)
		position_cible_y = position_initiale.y - hauteur_max * ratio_descente
	
	# Appliquer l'interpolation selon le type choisi
	match type_interpolation:
		TypeInterpolation.LINEAR:
			_interpolation_lineaire(position_cible_y, delta)
		TypeInterpolation.SMOOTH:
			_interpolation_smooth(position_cible_y, delta)
		TypeInterpolation.RESSORT:
			_interpolation_ressort(position_cible_y, delta)
		TypeInterpolation.ELASTIQUE:
			_interpolation_elastique(position_cible_y, delta)

func _interpolation_lineaire(cible_y: float, delta: float):
	var vitesse = vitesse_descente if global_position.y > cible_y else vitesse_montee
	var nouvelle_pos = global_position
	nouvelle_pos.y = move_toward(global_position.y, cible_y, vitesse * delta)
	global_position = nouvelle_pos

func _interpolation_smooth(cible_y: float, delta: float):
	# Interpolation exponentielle pour un mouvement doux
	var nouvelle_pos = global_position
	var vitesse = vitesse_descente if global_position.y > cible_y else vitesse_montee
	nouvelle_pos.y = lerp(global_position.y, cible_y, lissage * vitesse * delta * 0.1)
	global_position = nouvelle_pos

func _interpolation_ressort(cible_y: float, delta: float):
	# Simulation de ressort physique (Spring-Damper)
	var diff_y = cible_y - global_position.y
	var force_ressort = diff_y * durete_ressort
	var force_amortissement = -velocite_y * amortissement * 10.0
	
	# Appliquer les forces
	velocite_y += (force_ressort + force_amortissement) * delta
	
	# Mettre à jour la position
	var nouvelle_pos = global_position
	nouvelle_pos.y += velocite_y * delta
	global_position = nouvelle_pos

func _interpolation_elastique(cible_y: float, delta: float):
	# Effet élastique avec léger rebond
	var nouvelle_pos = global_position
	var diff = cible_y - global_position.y
	var vitesse = vitesse_descente if diff < 0 else vitesse_montee
	
	# Utiliser une interpolation cubique pour l'effet élastique
	var t = clamp(lissage * vitesse * delta * 0.15, 0.0, 1.0)
	var ease = _ease_out_elastic(t)
	
	nouvelle_pos.y = lerp(global_position.y, cible_y, ease)
	global_position = nouvelle_pos

func _ease_out_elastic(t: float) -> float:
	# Fonction d'assouplissement élastique
	if t == 0.0 or t == 1.0:
		return t
	var p = 0.3
	return pow(2.0, -10.0 * t) * sin((t - p / 4.0) * (2.0 * PI) / p) + 1.0

func calculer_poids_total():
	poids_actuel = 0.0
	
	for obj in objets_dessus:
		if is_instance_valid(obj) and obj is RigidBody3D:
			poids_actuel += obj.mass
		elif is_instance_valid(obj) and obj is CharacterBody3D:
			poids_actuel += 1.0
		elif is_instance_valid(obj):
			poids_actuel += 1.0

func _on_body_entered(body):
	if body != self and not body in objets_dessus:
		objets_dessus.append(body)

func _on_body_exited(body):
	if body in objets_dessus:
		objets_dessus.erase(body)
