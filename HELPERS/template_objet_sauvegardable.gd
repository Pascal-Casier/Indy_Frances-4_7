extends Node3D

# ===================================
# ÉTAPE 1 : AJOUTER L'ID DE SAUVEGARDE
# ===================================
@export var save_id : String  # OBLIGATOIRE : ID unique pour cet objet


# ===================================
# ÉTAPE 2 : DÉFINIR L'ÉTAT À SAUVEGARDER
# ===================================
# Exemples de ce que vous pouvez sauvegarder :
var is_collected := false      # Pour objets collectables
var is_destroyed := false      # Pour objets destructibles
var is_activated := false      # Pour interrupteurs, leviers
var current_state := 0         # Pour objets avec plusieurs états
var custom_position : Vector3  # Pour objets déplaçables


# ===================================
# ÉTAPE 3 : CHARGER L'ÉTAT AU _ready()
# ===================================
func _ready() -> void:
	# Vérifier que save_id est défini
	if save_id == "":
		push_error("%s has no save_id!" % name)
		return

	# Attendre que SaveSystem ait chargé
	if not SaveSystem.is_loaded:
		await get_tree().process_frame
	
	# Charger l'état sauvegardé
	load_state()


# ===================================
# ÉTAPE 4 : FONCTION DE CHARGEMENT
# ===================================
func load_state():
	if not SaveSystem.world_state.has(save_id):
		return  # Pas de sauvegarde pour cet objet
	
	var saved_data = SaveSystem.world_state[save_id]
	
	# Restaurer les variables
	is_collected = saved_data.get("collected", false)
	is_destroyed = saved_data.get("destroyed", false)
	is_activated = saved_data.get("activated", false)
	current_state = saved_data.get("state", 0)
	
	# Position (si vous sauvegardez la position)
	if saved_data.has("position"):
		var pos = saved_data["position"]
		custom_position = Vector3(pos.x, pos.y, pos.z)
	
	# Appliquer l'état visuel
	apply_visual_state()
	
	print("%s loaded state: %s" % [save_id, saved_data])


# ===================================
# ÉTAPE 5 : APPLIQUER L'ÉTAT VISUEL
# ===================================
func apply_visual_state():
	# Exemple pour objet collecté
	if is_collected:
		queue_free()  # Supprimer l'objet
		return
	
	# Exemple pour objet détruit
	if is_destroyed:
		hide()  # Ou queue_free()
		return
	
	# Exemple pour interrupteur
	if is_activated:
		# Jouer animation "on" ou changer matériau
		pass
	
	# Exemple pour états multiples
	match current_state:
		0: pass  # État initial
		1: pass  # État 1
		2: pass  # État 2


# ===================================
# ÉTAPE 6 : SAUVEGARDER QUAND CHANGEMENT
# ===================================
func save_state():
	# Construire le dictionnaire de données
	var data_to_save = {
		"collected": is_collected,
		"destroyed": is_destroyed,
		"activated": is_activated,
		"state": current_state
	}
	
	# Sauvegarder position si nécessaire
	if custom_position:
		data_to_save["position"] = {
			"x": custom_position.x,
			"y": custom_position.y,
			"z": custom_position.z
		}
	
	# Enregistrer dans le système
	SaveSystem.world_state[save_id] = data_to_save
	SaveSystem.save_game()
	
	print("%s saved: %s" % [save_id, data_to_save])


# ===================================
# ÉTAPE 7 : APPELER save_state() QUAND NÉCESSAIRE
# ===================================

# Exemple : Objet collecté
func collect():
	is_collected = true
	save_state()
	queue_free()

# Exemple : Objet détruit
func destroy():
	is_destroyed = true
	save_state()
	# Animation de destruction...
	queue_free()

# Exemple : Interrupteur activé
func activate():
	is_activated = !is_activated
	save_state()
	apply_visual_state()

# Exemple : Changer d'état
func change_state(new_state: int):
	current_state = new_state
	save_state()
	apply_visual_state()
