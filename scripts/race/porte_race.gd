# Porte.gd
extends Area3D

@export var index_reponse: int  # 0, 1 ou 2
@export var penalite_vitesse: float = 0.5  # multiplicateur si mauvaise porte

@onready var label_3d: Label3D = %Label3D

var index_bonne_reponse_courante: int = -1

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("voiture"):
		return
	if index_reponse == index_bonne_reponse_courante:
		print("Bonne porte !")
	else:
		body.get_parent().appliquer_penalite(penalite_vitesse)

func set_texte_reponse(texte: String) -> void:
	label_3d.text = texte
