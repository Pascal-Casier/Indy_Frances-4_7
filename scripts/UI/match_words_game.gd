extends Control

@export var queuing : bool = true


# --- DONNÉES DU JEU (Configurables dans l'Inspecteur) ---
@export var vocab_pairs: Dictionary = {
	"Bonjour": { "text": "Olá", "audio": "res://audio/bonjour.ogg" },
	"Chat": { "text": "Gato", "audio": "" },
	"Maison": { "text": "Casa", "audio": "res://audio/maison.ogg" },
	"Chien": { "text": "Cachorro", "audio": "" },
	"Soleil": { "text": "Sol", "audio": "" }
}

# --- SONS ---
@export var victory_audio: String = "res://assets/sounds/sfx/yipee.mp3" # Son de victoire optionnel

# --- PARAMÈTRES VISUELS (Juice) ---
@export var color_default: Color = Color.WHITE
@export var color_selected: Color = Color(1.0, 0.9, 0.5)
@export var color_correct: Color = Color(0.4, 1.0, 0.4)
@export var color_error: Color = Color(1.0, 0.3, 0.3)
@export var anim_duration: float = 0.2

# --- RÉFÉRENCES NŒUDS ---
@onready var left_column: VBoxContainer = %LeftColumn
@onready var right_column: VBoxContainer = %RightColumn
@onready var audio_player: AudioStreamPlayer = %AudioStreamPlayer

# --- VARIABLES D'ÉTAT ---
var selected_left_button: Button = null
var selected_right_button: Button = null
var matched_count: int = 0
var is_busy: bool = false

func _ready() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
	setup_game()

func setup_game() -> void:
	matched_count = 0
	is_busy = false
	
	# Nettoyer l'éventuel écran de victoire s'il existe
	var existing_popup = get_node_or_null("VictoryPopup")
	if existing_popup:
		existing_popup.queue_free()

	for child in left_column.get_children():
		child.queue_free()
	for child in right_column.get_children():
		child.queue_free()

	var left_items: Array = vocab_pairs.keys()
	var right_items: Array = []
	for key in left_items:
		right_items.append(vocab_pairs[key]["text"])

	left_items.shuffle()
	right_items.shuffle()

	for item in left_items:
		var btn: Button = _create_vocab_button(item, true)
		left_column.add_child(btn)

	for item in right_items:
		var btn: Button = _create_vocab_button(item, false)
		right_column.add_child(btn)

func _create_vocab_button(text_val: String, is_left: bool) -> Button:
	var btn: Button = Button.new()
	btn.text = text_val
	btn.resized.connect(func(): btn.pivot_offset = btn.size / 2)
	btn.modulate = color_default
	
	if is_left:
		btn.set_meta("id", text_val) 
		btn.pressed.connect(_on_left_button_pressed.bind(btn))
	else:
		btn.set_meta("id", text_val)
		btn.pressed.connect(_on_right_button_pressed.bind(btn))
		
	return btn

func _on_left_button_pressed(button: Button) -> void:
	if is_busy or button.disabled: return
	
	var key = button.get_meta("id")
	if vocab_pairs.has(key) and vocab_pairs[key]["audio"] != "":
		_play_sound(vocab_pairs[key]["audio"])

	if selected_left_button and selected_left_button != button:
		_animate_button(selected_left_button, color_default, Vector2(1.0, 1.0))

	selected_left_button = button
	_animate_button(selected_left_button, color_selected, Vector2(1.1, 1.1))
	
	_check_match()

func _on_right_button_pressed(button: Button) -> void:
	if is_busy or button.disabled: return

	if selected_right_button and selected_right_button != button:
		_animate_button(selected_right_button, color_default, Vector2(1.0, 1.0))

	selected_right_button = button
	_animate_button(selected_right_button, color_selected, Vector2(1.1, 1.1))

	_check_match()

func _check_match() -> void:
	if selected_left_button == null or selected_right_button == null:
		return

	var left_key = selected_left_button.get_meta("id")
	var right_text = selected_right_button.get_meta("id")

	if vocab_pairs.has(left_key) and vocab_pairs[left_key]["text"] == right_text:
		is_busy = true
		matched_count += 1
		
		_animate_button(selected_left_button, color_correct, Vector2(1.2, 1.2), true)
		_animate_button(selected_right_button, color_correct, Vector2(1.2, 1.2), true)
		
		selected_left_button.disabled = true
		selected_right_button.disabled = true
		
		await get_tree().create_timer(anim_duration * 2).timeout
		
		_animate_button(selected_left_button, color_correct, Vector2(1.0, 1.0))
		_animate_button(selected_right_button, color_correct, Vector2(1.0, 1.0))
		
		selected_left_button = null
		selected_right_button = null
		is_busy = false

		if matched_count >= vocab_pairs.size():
			_on_game_finished()
	else:
		is_busy = true
		
		_animate_button(selected_left_button, color_error, Vector2(1.0, 1.0))
		_animate_button(selected_right_button, color_error, Vector2(1.0, 1.0))
		_shake_button(selected_left_button)
		_shake_button(selected_right_button)
		
		await get_tree().create_timer(0.6).timeout
		
		_animate_button(selected_left_button, color_default, Vector2(1.0, 1.0))
		_animate_button(selected_right_button, color_default, Vector2(1.0, 1.0))
		
		selected_left_button = null
		selected_right_button = null
		is_busy = false

func _animate_button(button: Button, target_color: Color, target_scale: Vector2, quick: bool = false) -> void:
	if not is_instance_valid(button): return
	var tween = create_tween()
	tween.set_parallel(true) 
	
	var duration = anim_duration
	if quick: duration /= 2.0
	
	tween.tween_property(button, "modulate", target_color, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, duration)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _shake_button(button: Button) -> void:
	if not is_instance_valid(button): return
	var tween = create_tween()
	var original_pos = button.position
	var shake_offset = 5.0
	var shake_time = 0.05
	
	tween.tween_property(button, "position:x", original_pos.x + shake_offset, shake_time)
	tween.tween_property(button, "position:x", original_pos.x - shake_offset, shake_time)
	tween.tween_property(button, "position:x", original_pos.x + shake_offset, shake_time)
	tween.tween_property(button, "position:x", original_pos.x, shake_time)

func _play_sound(audio_path: String) -> void:
	if FileAccess.file_exists(audio_path):
		var stream = load(audio_path)
		if stream:
			audio_player.stream = stream
			audio_player.play()

func _on_game_finished() -> void:
	# Jouer le son de victoire
	if victory_audio != "":
		_play_sound(victory_audio)
		
	# Création dynamique d'un panneau de victoire centré
	var popup = PanelContainer.new()
	popup.name = "VictoryPopup"
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.custom_minimum_size = Vector2(350, 180)
	
	# Conteneur vertical interne pour le texte et le bouton
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	
	var label = Label.new()
	label.text = "🏆 BIEN JOUÈ !\nFélicitations, l'Aventurier !"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var restart_btn = Button.new()
	restart_btn.text = "Sortir"
	restart_btn.custom_minimum_size = Vector2(120, 40)
	restart_btn.pressed.connect(_on_exit_button_pressed) 
	
	# Centrer le bouton de redémarrage dans la boîte
	var center_box = CenterContainer.new()
	center_box.add_child(restart_btn)
	vbox.add_child(center_box)
	
	popup.add_child(vbox)
	add_child(popup)
	
	# Animation d'apparition du popup (Zoom fluide via Tween)
	popup.pivot_offset = popup.custom_minimum_size / 2
	popup.scale = Vector2(0.0, 0.0)
	var tween = create_tween()
	tween.tween_property(popup, "scale", Vector2(1.0, 1.0), 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_exit_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	if queuing:
		queue_free()
	else:
		hide()
