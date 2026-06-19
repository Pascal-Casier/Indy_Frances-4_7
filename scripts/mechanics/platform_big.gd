extends CharacterBody3D

@export var offset_arrivee : Vector3 = Vector3(5, 0, 0)  # décalage par rapport à la position initiale
@export var duree : float = 2.0  # durée du trajet en secondes

var position_depart : Vector3
var position_arrivee : Vector3
var tween : Tween


func _ready() -> void:
	# On récupère la position telle qu'elle est placée dans l'éditeur
	position_depart = global_position
	position_arrivee = position_depart + offset_arrivee
	_lancer_animation()


func _lancer_animation() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# Aller : position initiale → position initiale + offset
	tween.tween_property(self, "global_position", position_arrivee, duree)
	# Retour : position initiale + offset → position initiale
	tween.tween_property(self, "global_position", position_depart, duree)

	# Répéter indéfiniment
	tween.tween_callback(_lancer_animation)
