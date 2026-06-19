extends Node

## mouse texture
var texture = preload("res://assets/images/icons/StoneCursorMouse/PNG/01.png")  # Ton image

var health := 100
var coins : int = 6
var has_key := false
var has_keycard := false
var has_whip := false
var pausing := false
var book_lesson_number = 0
var can_glide := false
var can_light := true
var player_position := Vector3.ZERO
var mouse_sensitiv := 0.1 :
	set(value):
		mouse_sensitiv = value
		emit_signal("mouse_sensitivity_changed", value)
var niveau_number : int = 1 :
	set(value):
		var ancien = niveau_number
		niveau_number = maxi(value, ancien)  # on ne recule jamais
		if niveau_number != ancien:
			niveau_debloque_change.emit()  # ← on notifie tout le monde
		# Sauvegarder automatiquement quand le niveau change
			if SaveSystem.is_loaded:
				SaveSystem.save_game()
				print("Niveau %d débloqué et sauvegardé!" % niveau_number)

enum GameMode { PLAY, READING }
var mode : GameMode = GameMode.PLAY


# Signal directement dans l'autoload → tout le monde peut l'écouter
signal niveau_debloque_change

var mots_trouves : Array[String] = []
var total_mots_attendus : int = 10  # nombre total de mots à trouver dans ce niveau

var notes = []

signal mouse_sensitivity_changed(new_value)
signal on_coins_updated
signal on_health_updated
signal on_key_found
signal on_pause_mode
signal open_door_gate
signal on_new_book_found
signal spawn(index)
@warning_ignore("unused_signal")
signal on_keycard_found
@warning_ignore("unused_signal")
signal letter_picked_up(letter)
@warning_ignore("unused_signal")
signal has_sword
signal new_note
@warning_ignore("unused_signal")
signal note_collected(french_words, portuguese_words, category)
signal words_found_number()
@warning_ignore("unused_signal")
signal show_tuto(value : bool)
@warning_ignore("unused_signal")
signal light_on(value : bool)
@warning_ignore("unused_signal")
signal lantern_off
@warning_ignore("unused_signal")
signal full_battery
signal switch_changed(id: String, is_on: bool)

#signal health_update

#func emit_health_update():
	#health_update.emit()

func _ready() -> void:
	Input.set_custom_mouse_cursor(
	texture,              # Image
	#Input.CURSOR_ARROW,   # Forme de base (optionnel)
	#Vector2(8, 8)         # Hotspot (point de clic, ex: pointe de flèche)
)
	save_settings()
	load_settings()
	
func set_switch(id: String, is_on: bool) -> void:
	emit_signal("switch_changed", id, is_on)

func input_allowed() -> bool:
	return mode == GameMode.PLAY
			
func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "mouse_sensitivity", mouse_sensitiv)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		mouse_sensitiv = config.get_value("settings", "mouse_sensitivity", 0.5)

func ajouter_mot(mot: String) -> void:
	if not mots_trouves.has(mot):
		mots_trouves.append(mot)
		Dialogic.VAR.set('mots_trouves', mots_trouves.size())
		words_found_number.emit(mots_trouves.size())

func tous_les_mots_trouves() -> bool:
	return mots_trouves.size() >= total_mots_attendus
	
func emit_coins_updated():
	on_coins_updated.emit(coins)
#
func emit_health_update():
	on_health_updated.emit(health)

func emit_key_found():
	on_key_found.emit(has_key)

func emit_on_pause_mode():
	on_pause_mode.emit(pausing)

func emit_open_door_gate(door_nbr : int):
	open_door_gate.emit(door_nbr)

func emit_on_new_book_found_signal() -> void:
	book_lesson_number += 1
	on_new_book_found.emit()

func emit_spawn_signal(index):
	spawn.emit(index)

func add_note(title: String, content: String):
	var note = {
		"title": title,
		"content": content
	}
	notes.append(note)
	new_note.emit()
	
