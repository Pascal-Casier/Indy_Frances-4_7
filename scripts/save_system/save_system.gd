extends Node

# =============================
# CONFIG
# =============================

const MAX_SLOTS := 3
var current_slot := 1

# =============================
# DONNÉES PERSISTANTES
# =============================

var world_state : Dictionary = {}
var is_loaded := false

# =============================
# SAUVEGARDE DIFFÉRÉE
# =============================

var save_timer : Timer
var pending_save := false

signal save_loaded  # Signal pour notifier que le chargement est terminé

# =============================
# INITIALISATION
# =============================

func _ready():
	# Créer le timer de sauvegarde différée
	save_timer = Timer.new()
	save_timer.wait_time = 2.0  # Attend 2 secondes avant de sauvegarder
	save_timer.one_shot = true
	save_timer.timeout.connect(_on_save_timer_timeout)
	add_child(save_timer)
	
	# Charger la sauvegarde
	load_game()
	is_loaded = true
	save_loaded.emit()  # Notifier que le chargement est terminé
	
	#print("SaveSystem ready. World state:", world_state)

func get_save_path(slot: int) -> String:
	return "user://SaveFile%d.json" % slot

# =============================
# SAUVEGARDE DIFFÉRÉE
# =============================

func request_save():
	#"""Demande une sauvegarde différée (pour éviter trop d'écritures disque)"""
	pending_save = true
	if save_timer.is_stopped():
		save_timer.start()

func _on_save_timer_timeout():
	if pending_save:
		save_game()
		pending_save = false

# =============================
# CONSTRUCTION DES DONNÉES
# =============================

func get_save_data() -> Dictionary:
	return {
		# --- Données joueur ---
		"health": Global.health,
		"coins": Global.coins,
		"has_key": Global.has_key,
		"has_keycard": Global.has_keycard,
		"book_lesson_number": Global.book_lesson_number,
		"can_glide": Global.can_glide,
		"niveau_number": Global.niveau_number,
		"player_position": {
			"x": Global.player_position.x,
			"y": Global.player_position.y,
			"z": Global.player_position.z
		},

		# --- Monde ---
		"world_state": world_state
	}

# =============================
# SAUVEGARDE
# =============================

func save_game(slot := current_slot):
	var path = get_save_path(slot)
	var data = get_save_data()
	
	#print("=== SAVING GAME ===")
	#print("Path:", path)
	#print("Coins collected: %d" % len(world_state.keys()))
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("Impossible de sauvegarder dans: %s (Error: %d)" % [path, error])
		return
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	#
	#print("Sauvegarde effectuée!")
	#print("===================")

# =============================
# CHARGEMENT
# =============================

func load_game(slot := current_slot):
	var path = get_save_path(slot)

	if not FileAccess.file_exists(path):
		#print("No save file found at:", path)
		#print("Creating new save...")
		save_game(slot)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Impossible de lire: " + path)
		return
		
	var text := file.get_as_text()
	file.close()
	
	#print("=== LOADING GAME ===")

	if text.strip_edges() == "":
		#print("Save file is empty. Creating new save...")
		save_game(slot)
		return

	var json = JSON.new()
	var parse_result = json.parse(text)
	
	if parse_result != OK:
		push_error("JSON Parse Error: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		#print("Corrupted save. Creating new save...")
		save_game(slot)
		return
	
	var data = json.data
	
	if data == null or not data is Dictionary or data.is_empty():
		push_error("Save file corrupted or invalid JSON.")
		#print("Creating new save...")
		save_game(slot)
		return

	# --- Joueur ---
	Global.health = data.get("health", Global.health)
	Global.coins = data.get("coins", Global.coins)
	Global.has_key = data.get("has_key", false)
	Global.has_keycard = data.get("has_keycard", false)
	Global.book_lesson_number = data.get("book_lesson_number", 0)
	Global.can_glide = data.get("can_glide", false)
	Global.niveau_number = data.get("niveau_number", 1)
	
	# Reconstituer le Vector3
	var pos_data = data.get("player_position", {"x": 0, "y": 0, "z": 0})
	Global.player_position = Vector3(
		pos_data.get("x", 0),
		pos_data.get("y", 0),
		pos_data.get("z", 0)
	)

	# --- Monde ---
	world_state = data.get("world_state", {})

	#print("SAVE LOADED successfully!")
	#print("Level: %d" % Global.niveau_number)
	#print("Coins in world_state: %d" % len(world_state.keys()))
	#print("====================")
