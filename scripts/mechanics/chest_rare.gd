extends Node3D

# =============================
# EXPORTS
# =============================
@export var save_id : String
@export var highlight_material: StandardMaterial3D
@export var object_to_spawn : PackedScene
@export var need_key := false
@export var timeline_name : String

# =============================
# NODES
# =============================
@onready var animation_player = $AnimationPlayer
@onready var chest_top = $chestTop_rare
@onready var chest_material: StandardMaterial3D = chest_top.mesh.surface_get_material(0)
@onready var label = $Control/Label
@onready var spawn_point: Marker3D = %spawn_point
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# =============================
# STATE
# =============================
var is_open := false

# =============================
# INITIALIZATION
# =============================

func _ready() -> void:
	# Validation du save_id
	if save_id == "":
		push_error("Chest '%s' has no save_id! Destroying." % name)
		queue_free()
		return
	
	# Vérifier le format (optionnel)
	if not save_id.begins_with("level"):
		push_warning("Chest '%s' has non-standard save_id: %s" % [name, save_id])
	
	# Attendre que SaveSystem soit complètement chargé
	if not SaveSystem.is_loaded:
		await SaveSystem.save_loaded  # Utilise le signal au lieu d'un timer
	
	print("Checking chest '%s'. World state keys: %d" % [save_id, len(SaveSystem.world_state.keys())])
	
	# Vérifier si ce coffre était déjà ouvert
	if SaveSystem.world_state.has(save_id):
		is_open = SaveSystem.world_state[save_id].get("open", false)
		print("Chest '%s' was previously opened: %s" % [save_id, is_open])
		
		if is_open:
			apply_open_state()
	else:
		print("Chest '%s' is new (not in save)" % save_id)

# =============================
# STATE MANAGEMENT
# =============================

func apply_open_state():
	"""Applique visuellement l'état 'ouvert' sans animation"""
	# Si vous avez créé une animation "opened" statique
	if animation_player.has_animation("opened"):
		animation_player.play("opened")
	else:
		# Sinon, aller à la fin de l'animation d'ouverture
		if animation_player.has_animation("open_chest"):
			var anim_length = animation_player.get_animation("open_chest").length
			animation_player.play("open_chest")
			animation_player.seek(anim_length, true)
			animation_player.stop()
	
	# Désactiver les interactions
	remove_highlight()
	label.hide()

	# Supprimer le nœud Interactable s'il existe
	if has_node("Interactable"):
		$Interactable.queue_free()
	
	print("Chest '%s' visually set to OPEN state" % save_id)

func open_chest():
	"""Ouvre le coffre (appelé par interaction)"""
	if is_open:
		return

	print("=== OPENING CHEST '%s' ===" % save_id)
	
	is_open = true
	animation_player.play("open_chest")
	remove_highlight()
	label.hide()
	
	# Supprimer l'Interactable s'il existe
	if has_node("Interactable"):
		$Interactable.queue_free()

	# Spawn l'objet si défini
	spawn_object()

	# Sauvegarder l'état du coffre
	SaveSystem.world_state[save_id] = {
		"open": true
	}
	
	print("Chest '%s' opened. Requesting save..." % save_id)
	
	# OPTION 1: Sauvegarde différée (recommandé)
	SaveSystem.request_save()
	
	# OPTION 2: Sauvegarde immédiate (si critique)
	# SaveSystem.save_game()
	
	print("=========================")

# =============================
# VISUAL FEEDBACK
# =============================

func add_highlight() -> void:
	chest_top.set_surface_override_material(0, chest_material.duplicate())
	chest_top.get_surface_override_material(0).next_pass = highlight_material
	
func remove_highlight() -> void:
	chest_top.set_surface_override_material(0, null)

func spawn_object():
	"""Fait apparaître l'objet du coffre"""
	if object_to_spawn:
		var object = object_to_spawn.instantiate()
		get_parent().add_child(object)
		object.global_position = spawn_point.global_position
		print("Spawned object from chest '%s'" % save_id)

# =============================
# INTERACTABLE CALLBACKS
# =============================

@warning_ignore("unused_parameter")
func _on_interactable_focused(interactor):
	if not is_open:
		add_highlight()
		label.show()

@warning_ignore("unused_parameter")
func _on_interactable_interacted(interactor):
	if not is_open:
		# Vérifier si une clé est nécessaire
		if need_key and not Global.has_key:
			audio_stream_player.play()  # Son de refus
			print("Chest '%s' needs a key!" % save_id)
			return
		
		open_chest()

@warning_ignore("unused_parameter")
func _on_interactable_unfocused(interactor):
	if not is_open:
		remove_highlight()
		label.hide()

# =============================
# AREA DETECTION (si pas d'Interactable)
# =============================

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_open:
		label.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label.hide()

# =============================
# INPUT HANDLING (si pas d'Interactable)
# =============================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and label.visible and not is_open:
		if need_key and not Global.has_key:
			audio_stream_player.play()  # Son de refus
			print("Chest '%s' needs a key!" % save_id)
		else:
			open_chest()

# =============================
# ANIMATION CALLBACKS
# =============================

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open_chest":
		# Optionnel: démarrer un dialogue après ouverture
		if timeline_name != "":
			await get_tree().create_timer(1.0).timeout
			start_dialogue()

# =============================
# DIALOGUE SYSTEM
# =============================

func start_dialogue() -> void:
	#"""Démarre un dialogue Dialogic si configuré"""
	if timeline_name == "":
		return
	
	if Dialogic.current_timeline != null:
		return
	
	Dialogic.start(timeline_name)
	get_viewport().set_input_as_handled()
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_ended():
	pass
	# Exemple: changer de niveau après le dialogue
	# Loader.chang_level("res://scenes/levels/niveau_dream_01.tscn")
	
