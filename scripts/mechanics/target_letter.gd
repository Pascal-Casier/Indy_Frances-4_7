extends Node3D

@export var lettre: String:
	set(value):
		lettre = value
		if label_3d:
			label_3d.text = lettre

signal cible_touchee(lettre: String)
@onready var label_3d: Label3D = %Label3D
@onready var area_3d: Area3D = %Area3D
@onready var collision_shape_3d: CollisionShape3D = $targetStand_gltf/targetStand/StaticBody3D/CollisionShape3D

func _ready() -> void:
	label_3d.text = lettre

# Méthode sécurisée avec set_deferred pour éviter le blocage physique
func set_actif(actif: bool) -> void:
	visible = actif
	if area_3d:
		area_3d.set_deferred("monitoring", actif)
		area_3d.set_deferred("monitorable", actif)
		collision_shape_3d.set_deferred("disabled", !actif)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Pickeable"):
		$AudioStreamPlayer.play()
		%AnimationPlayer.play("bullseye")
		cible_touchee.emit(lettre)
