## ========================================
## EXEMPLE 1 : PIÈCE / COLLECTABLE
## ========================================
extends Node3D
#
#@export var save_id : String
#@export var coin_value := 1
#
#func _ready():
	#if save_id == "":
		#push_error("Coin has no save_id!")
		#return
	#
	#if not SaveSystem.is_loaded:
		#await get_tree().process_frame
	#
	## Si déjà collectée, supprimer
	#if SaveSystem.world_state.has(save_id):
		#if SaveSystem.world_state[save_id].get("collected", false):
			#queue_free()
#
#func _on_body_entered(body):
	#if body.is_in_group("Player"):
		#collect()
#
#func collect():
	#Global.coins += coin_value
	#
	## Sauvegarder
	#SaveSystem.world_state[save_id] = {"collected": true}
	#SaveSystem.save_game()
	#
	#queue_free()
#
#
## ========================================
## EXEMPLE 2 : PORTE VERROUILLÉE
## ========================================
#extends Node3D
#
#@export var save_id : String
#@export var needs_key := true
#@onready var animation_player = $AnimationPlayer
#
#var is_open := false
#
#func _ready():
	#if save_id == "":
		#push_error("Door has no save_id!")
		#return
	#
	#if not SaveSystem.is_loaded:
		#await get_tree().process_frame
	#
	## Charger l'état
	#if SaveSystem.world_state.has(save_id):
		#is_open = SaveSystem.world_state[save_id].get("open", false)
		#if is_open:
			#apply_open_state()
#
#func apply_open_state():
	#if animation_player.has_animation("opened"):
		#animation_player.play("opened")
	#else:
		#animation_player.play("open")
		#animation_player.seek(animation_player.get_animation("open").length, true)
		#animation_player.stop()
#
#func open_door():
	#if is_open:
		#return
	#
	#if needs_key and not Global.has_key:
		#print("Vous avez besoin d'une clé!")
		#return
	#
	#is_open = true
	#animation_player.play("open")
	#
	## Sauvegarder
	#SaveSystem.world_state[save_id] = {"open": true}
	#SaveSystem.save_game()
#
#
## ========================================
## EXEMPLE 3 : INTERRUPTEUR / LEVIER
## ========================================
#extends Node3D
#
#@export var save_id : String
#@onready var animation_player = $AnimationPlayer
#
#var is_activated := false
#
#signal switch_toggled(activated: bool)
#
#func _ready():
	#if save_id == "":
		#push_error("Switch has no save_id!")
		#return
	#
	#if not SaveSystem.is_loaded:
		#await get_tree().process_frame
	#
	## Charger l'état
	#if SaveSystem.world_state.has(save_id):
		#is_activated = SaveSystem.world_state[save_id].get("activated", false)
		#apply_state()
#
#func apply_state():
	#if is_activated:
		#animation_player.play("on")
	#else:
		#animation_player.play("off")
	#
	## Émettre le signal pour activer d'autres objets
	#switch_toggled.emit(is_activated)
#
#func toggle():
	#is_activated = !is_activated
	#apply_state()
	#
	## Sauvegarder
	#SaveSystem.world_state[save_id] = {"activated": is_activated}
	#SaveSystem.save_game()
#
#
## ========================================
## EXEMPLE 4 : ENNEMI / PNJ
## ========================================
#extends CharacterBody3D
#
#@export var save_id : String
#@export var max_health := 100
#
#var current_health := max_health
#var is_dead := false
#
#func _ready():
	#if save_id == "":
		#push_error("Enemy has no save_id!")
		#return
	#
	#if not SaveSystem.is_loaded:
		#await get_tree().process_frame
	#
	## Charger l'état
	#if SaveSystem.world_state.has(save_id):
		#var data = SaveSystem.world_state[save_id]
		#is_dead = data.get("dead", false)
		#current_health = data.get("health", max_health)
		#
		#if is_dead:
			#queue_free()  # Supprimer si déjà mort
#
#func take_damage(amount: int):
	#if is_dead:
		#return
	#
	#current_health -= amount
	#
	#if current_health <= 0:
		#die()
	#else:
		## Sauvegarder la santé actuelle
		#SaveSystem.world_state[save_id] = {
			#"health": current_health,
			#"dead": false
		#}
		#SaveSystem.save_game()
#
#func die():
	#is_dead = true
	#
	## Sauvegarder la mort
	#SaveSystem.world_state[save_id] = {
		#"health": 0,
		#"dead": true
	#}
	#SaveSystem.save_game()
	#
	## Animation de mort...
	#queue_free()
#
#
## ========================================
## EXEMPLE 5 : OBJET DÉPLAÇABLE (BLOC, CAISSE)
## ========================================
##extends RigidBody3D
#
#@export var save_id : String
#
#func _ready():
	#if save_id == "":
		#push_error("Moveable has no save_id!")
		#return
	#
	#if not SaveSystem.is_loaded:
		#await get_tree().process_frame
	#
	## Charger la position
	#if SaveSystem.world_state.has(save_id):
		#var pos = SaveSystem.world_state[save_id].get("position")
		#if pos:
			#global_position = Vector3(pos.x, pos.y, pos.z)
#
#func save_position():
	#SaveSystem.world_state[save_id] = {
		#"position": {
			#"x": global_position.x,
			#"y": global_position.y,
			#"z": global_position.z
		#}
	#}
	#SaveSystem.save_game()
#
## Appeler cette fonction quand l'objet arrête de bouger
#func _on_sleeping_state_changed():
	#if sleeping:
		#save_position()
