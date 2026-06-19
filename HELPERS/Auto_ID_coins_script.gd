@tool
extends Node3D

# Changez ce nom selon votre niveau
@export var level_name : String = "lvl1"

# Bouton pour lancer l'auto-nommage
@export var auto_name_coins : bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			name_all_coins()

func name_all_coins():
	var index = 1
	var named_count = 0
	
	print("=== AUTO-NAMING COINS ===")
	
	for child in get_children():
		# Vérifier si c'est bien une pièce (Area3D avec le script coin.gd)
		if child is Area3D and child.has_method("collect"):
			# Créer l'ID unique
			var new_id = "coin_%s_%02d" % [level_name, index]
			child.save_id = new_id
			named_count += 1
			print("Named: %s -> %s" % [child.name, new_id])
			index += 1
	
	print("=========================")
	print("✅ %d coins auto-named!" % named_count)
	print("=========================")
