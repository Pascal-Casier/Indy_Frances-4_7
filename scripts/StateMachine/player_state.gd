class_name PlayerState
extends Node

# Référence au joueur
var player: CharacterBody3D
var animation_tree: AnimationTree

func _ready():
	pass

# Appelé quand on entre dans l'état
func enter() -> void:
	pass

# Appelé quand on sort de l'état
func exit() -> void:
	pass

# Appelé chaque frame
func update(_delta: float) -> void:
	pass

# Appelé chaque physics frame - retourne le nom du prochain état ou null
func physics_update(_delta: float) -> String:
	return ""

# Gestion des inputs - retourne le nom du prochain état ou null
func handle_input(_event: InputEvent) -> String:
	return ""

# ---------------------------------------------------------------------------
# Helpers pour toucher l'AnimationTree en sécurité.
# Si animation_tree est null (scène de test sans modèle), ça ne fait rien.
# ---------------------------------------------------------------------------
func anim_set(param: String, value) -> void:
	if animation_tree:
		animation_tree[param] = value

func anim_travel(param: String, dest: String) -> void:
	if animation_tree:
		animation_tree[param].travel(dest)
