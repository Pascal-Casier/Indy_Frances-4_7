extends Node3D

var target_scene = preload("res://scenes/mechanics/word_target.tscn")
var spawn_positions = []
var active_targets = []

func _ready():
	# Définir les positions de spawn (ajustez selon votre scène)
	spawn_positions = [
		Vector3(-7, 2, 0),
		Vector3(-3, 4, -1),
		Vector3(3, 1, 1),
		Vector3(7, 3.5, 0.5)
	]

func spawn_targets(french_words: Array):
	# Supprimer les anciennes cibles
	clear_targets()
	
	# Créer de nouvelles cibles
	for i in range(french_words.size()):
		if i < spawn_positions.size():
			var target = target_scene.instantiate()
			add_child(target)
			
			target.position = spawn_positions[i]
			target.set_word(french_words[i])
			target.target_hit.connect(_on_target_hit)
			
			active_targets.append(target)

func clear_targets():
	for target in active_targets:
		if is_instance_valid(target):
			target.queue_free()
	active_targets.clear()

func _on_target_hit(french_word: String):
	# Transmettre le signal au GameManager
	get_parent().on_target_hit(french_word)
