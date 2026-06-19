# bullet.gd
extends RigidBody3D

@export var speed: float = 20.0
@export var lifetime: float = 5.0

func _ready():
	# Détruire automatiquement après le temps de vie
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	# Ne pas se détruire en touchant le canon lui-même
	if body != get_node("/root/Canon3D"):  # Ajuste le chemin selon ta scène
		queue_free()  # Se détruire au contact

# Connecte le signal body_entered dans l'inspecteur
