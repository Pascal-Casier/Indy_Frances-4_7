class_name PlatformSwitch
extends Area3D

signal toggled
@export var is_active: bool = false:
	set(value):
		is_active = value
		visible = value
		# Désactive/Active la collision de manière différée (Deferred) pour la physique de Godot
		for child in get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", !value)

func _ready() -> void:
	# Par défaut, masque et désactive la collision au lancement
	self.is_active = false
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	# Vérifie si l'interrupteur est actif et si le corps entrant est le joueur
	if is_active and (body.is_in_group("player") or body is CharacterBody3D):
		toggled.emit()
