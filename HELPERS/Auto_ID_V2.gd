#### **Configuration dans l'éditeur**
#1. Attache ce script à la racine de ton niveau
#2. Configure `level_number` (ex: 1 pour level1, 2 pour level2...)
#3. Clique sur les boutons selon tes besoins :
   #- `auto_name_coins` → Nomme uniquement les coins
   #- `auto_name_chests` → Nomme uniquement les coffres
   #- `auto_name_all` → Nomme tout d'un coup
#
#### **Options avancées**
#- `check_duplicates` : Détecte et ignore les IDs déjà utilisés
#- `recursive_search` : Cherche dans toute l'arborescence (pas seulement les enfants directs)
#
### ⚡ **Exemple de sortie**
#```
#=== AUTO-NAMING COINS ===
#Found 15 coins
#✓ Named: Coin -> level1_coin_001
#✓ Named: Coin2 -> level1_coin_002
#✓ Named: Coin3 -> level1_coin_003
#⚠️ DUPLICATE ID: level1_coin_004 already exists! Skipping coin 'Coin4'
#✓ Named: Coin5 -> level1_coin_005
#=========================
#✅ 14 coins named, 1 skipped

@tool
extends Node3D

# =============================
# CONFIGURATION
# =============================

# Numéro du niveau (ex: 1, 2, 3...)
@export var level_number : int = 1

# Options d'auto-nommage
@export_group("Auto-Naming")
@export var auto_name_coins : bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			name_all_coins()

@export var auto_name_chests : bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			name_all_chests()

@export var auto_name_all : bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			name_all_items()

# Options avancées
@export_group("Advanced")
@export var check_duplicates : bool = true
@export var recursive_search : bool = true  # Chercher dans les enfants des enfants

# =============================
# FONCTIONS PRINCIPALES
# =============================

func name_all_items():
	"""Nomme tous les objets collectables du niveau"""
	print("=== AUTO-NAMING ALL ITEMS ===")
	name_all_coins()
	name_all_chests()
	print("=============================")

func name_all_coins():
	"""Nomme automatiquement toutes les pièces"""
	var coins = find_collectables("coin")
	
	if coins.is_empty():
		print("⚠️ No coins found!")
		return
	
	print("=== AUTO-NAMING COINS ===")
	print("Found %d coins" % coins.size())
	
	var used_ids = get_all_existing_ids() if check_duplicates else {}
	var index = 1
	var named_count = 0
	var skipped_count = 0
	
	for coin in coins:
		# Créer l'ID unique au format "levelX_coin_XXX"
		var new_id = "level%d_coin_%03d" % [level_number, index]
		
		# Vérifier les doublons
		if check_duplicates and used_ids.has(new_id):
			print("⚠️ DUPLICATE ID: %s already exists! Skipping coin '%s'" % [new_id, coin.name])
			skipped_count += 1
			index += 1
			continue
		
		# Assigner l'ID
		coin.save_id = new_id
		used_ids[new_id] = true
		named_count += 1
		print("✓ Named: %s -> %s" % [coin.name, new_id])
		index += 1
	
	print("=========================")
	print("✅ %d coins named, %d skipped" % [named_count, skipped_count])
	print("=========================")

func name_all_chests():
	"""Nomme automatiquement tous les coffres"""
	var chests = find_collectables("chest")
	
	if chests.is_empty():
		print("⚠️ No chests found!")
		return
	
	print("=== AUTO-NAMING CHESTS ===")
	print("Found %d chests" % chests.size())
	
	var used_ids = get_all_existing_ids() if check_duplicates else {}
	var index = 1
	var named_count = 0
	var skipped_count = 0
	
	for chest in chests:
		# Format spécial pour les coffres: "levelX_chest_XXX"
		var new_id = "level%d_chest_%03d" % [level_number, index]
		
		# Vérifier les doublons
		if check_duplicates and used_ids.has(new_id):
			print("⚠️ DUPLICATE ID: %s already exists! Skipping chest '%s'" % [new_id, chest.name])
			skipped_count += 1
			index += 1
			continue
		
		# Assigner l'ID
		chest.save_id = new_id
		used_ids[new_id] = true
		named_count += 1
		print("✓ Named: %s -> %s" % [chest.name, new_id])
		index += 1
	
	print("==========================")
	print("✅ %d chests named, %d skipped" % [named_count, skipped_count])
	print("==========================")

# =============================
# FONCTIONS UTILITAIRES
# =============================

func find_collectables(type: String) -> Array:
	"""Trouve tous les objets d'un type donné (coin ou chest)"""
	var items = []
	
	if recursive_search:
		items = find_collectables_recursive(self, type)
	else:
		items = find_collectables_direct(self, type)
	
	return items

func find_collectables_direct(node: Node, type: String) -> Array:
	"""Cherche uniquement dans les enfants directs"""
	var items = []
	
	for child in node.get_children():
		if is_collectable_of_type(child, type):
			items.append(child)
	
	return items

func find_collectables_recursive(node: Node, type: String) -> Array:
	"""Cherche récursivement dans tous les descendants"""
	var items = []
	
	for child in node.get_children():
		if is_collectable_of_type(child, type):
			items.append(child)
		
		# Récursion
		items.append_array(find_collectables_recursive(child, type))
	
	return items

func is_collectable_of_type(node: Node, type: String) -> bool:
	"""Vérifie si un nœud est un collectable du type demandé"""
	
	# Vérifier que le nœud a la propriété save_id
	if not "save_id" in node:
		return false
	
	match type:
		"coin":
			# Un coin est typiquement un Area3D avec la méthode collect()
			return node is Area3D and node.has_method("collect")
		
		"chest":
			# Un coffre est typiquement un Node3D avec la méthode open_chest()
			return node is Node3D and node.has_method("open_chest")
	
	return false

func get_all_existing_ids() -> Dictionary:
	"""Récupère tous les save_id existants pour détecter les doublons"""
	var ids = {}
	var all_nodes = find_all_nodes_with_save_id(self)
	
	for node in all_nodes:
		if node.save_id != "":
			if ids.has(node.save_id):
				print("⚠️ WARNING: Duplicate ID found: %s" % node.save_id)
			ids[node.save_id] = true
	
	return ids

func find_all_nodes_with_save_id(node: Node) -> Array:
	"""Trouve tous les nœuds qui ont une propriété save_id"""
	var nodes = []
	
	if "save_id" in node:
		nodes.append(node)
	
	for child in node.get_children():
		nodes.append_array(find_all_nodes_with_save_id(child))
	
	return nodes

# =============================
# VALIDATION
# =============================

func _ready():
	if not Engine.is_editor_hint():
		return
	
	# Validation au démarrage de l'éditeur
	if level_number <= 0:
		push_warning("Level number should be > 0. Current: %d" % level_number)
