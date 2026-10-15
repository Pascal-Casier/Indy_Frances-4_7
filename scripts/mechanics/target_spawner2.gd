extends Node3D

var target_scene = preload("res://scenes/mechanics/word_target.tscn")
var active_targets = []

# Une ligne par cible : Y fixe, Z identique pour toutes
@export var line_heights: Array[float] = [1.0, 2.0, 3.0, 4.0]
@export var line_z: float = 0.0
@export var x_limit: float = 7.0
@export var min_speed: float = 1.5
@export var max_speed: float = 3.0

func spawn_targets(french_words: Array):
	clear_targets()

	for i in range(french_words.size()):
		if i >= line_heights.size():
			break

		var target = target_scene.instantiate()
		add_child(target)

		# Position de départ : X aléatoire, Y/Z fixés par la ligne
		target.position = Vector3(
			randf_range(-x_limit + 1.0, x_limit - 1.0),
			line_heights[i],
			line_z
		)

		# Sens alterné d'une ligne à l'autre + vitesse propre à chaque ligne
		target.move_direction = 1.0 if i % 2 == 0 else -1.0
		target.move_speed = randf_range(min_speed, max_speed)
		target.x_limit = x_limit

		target.set_word(french_words[i])
		target.target_hit.connect(_on_target_hit)

		active_targets.append(target)

func clear_targets():
	for target in active_targets:
		if is_instance_valid(target):
			target.queue_free()
	active_targets.clear()

func _on_target_hit(french_word: String):
	get_parent().on_target_hit(french_word)
