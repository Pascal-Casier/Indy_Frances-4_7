extends Node3D

@onready var grille: MeshInstance3D = %Grille

@export var total_steps = 5  # Nombre total de bonnes réponses nécessaires
@export var door_max_angle = 90.0  # Angle maximal d'ouverture
@export var animation_duration = 0.5  # Durée de l'animation en secondes
@export var transition_type: Tween.TransitionType = Tween.TRANS_QUAD  # Type de transition
@export var ease_type: Tween.EaseType = Tween.EASE_OUT  # Type d'easing

var current_steps = 0
var current_tween: Tween

func animate_door():
	# Calcule l'angle cible basé sur la progression
	var target_angle = (float(current_steps) / total_steps) * door_max_angle
	
	# Arrête le tween précédent s'il existe
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	# Crée un nouveau tween
	current_tween = create_tween()
	current_tween.set_trans(transition_type)
	current_tween.set_ease(ease_type)
	
	# Anime la rotation de la porte
	current_tween.tween_property(
		grille,
		"rotation_degrees:y",
		target_angle,
		animation_duration
	)

func handle_answer(is_correct: bool):
	if is_correct:
		current_steps = min(current_steps + 1, total_steps)
	else:
		current_steps = max(current_steps - 1, 0)
	
	animate_door()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		handle_answer(true)
