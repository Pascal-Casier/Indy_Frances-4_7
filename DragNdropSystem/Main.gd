extends Control

signal success
# ─────────────────────────────────────────────
#  DONNÉES : éditables via l'inspecteur Godot
# ─────────────────────────────────────────────

## Liste des phrases du jeu — assignez des ressources PhraseData dans l'inspecteur
@export var phrases: Array[PhraseData] = []

## Si vrai, recharge automatiquement la scène quand phrases est modifié en éditeur
@export var auto_reload_in_editor: bool = true

# ─────────────────────────────────────────────
#  VARIABLES
# ─────────────────────────────────────────────
var current_phrase_index := 0
var drop_slots: Array = []      # noeuds DropSlot dans l'ordre
var word_cards: Array = []      # tous les WordCard du word bank

@onready var phrase_container = %PhraseContainer
@onready var word_bank        = %WordBank
@onready var result_label     = %ResultLabel
@onready var check_button     = %CheckButton
@onready var reset_button     = $%ResetButton
@onready var next_button      = %NextButton

# ─────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────
func _ready():
	check_button.pressed.connect(_on_check)
	reset_button.pressed.connect(_on_reset)
	next_button.pressed.connect(_on_next)
	if phrases.is_empty():
		_show_empty_state()
		return
	_load_phrase(current_phrase_index)

func _show_empty_state():
	result_label.text = "⚠ Aucune phrase configurée.\nAjoutez des ressources PhraseData dans l'inspecteur !"
	#result_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
	check_button.disabled = true

# ─────────────────────────────────────────────
#  CONSTRUCTION DE LA PHRASE
# ─────────────────────────────────────────────
func _load_phrase(index: int):
	# Nettoyage
	for child in phrase_container.get_children():
		child.queue_free()
	for child in word_bank.get_children():
		child.queue_free()
	drop_slots.clear()
	word_cards.clear()
	result_label.text = ""
	next_button.visible = false
	check_button.disabled = false

	var data = phrases[index]
	var slot_index := 0

	# Construction token par token
	for token in data.tokens:
		if token == "TROU":
			var slot = _make_drop_slot(slot_index)
			phrase_container.add_child(slot)
			drop_slots.append(slot)
			slot_index += 1
		else:
			var lbl = _make_static_word(token)
			phrase_container.add_child(lbl)

	# Construction du word bank (réponses + distracteurs mélangés)
	var all_words: Array = Array(data.answers)
	all_words.append_array(data.distractors)
	all_words.shuffle()

	for word in all_words:
		var card = _make_word_card(word)
		word_bank.add_child(card)
		word_cards.append(card)

# ─────────────────────────────────────────────
#  FACTORY : label statique
# ─────────────────────────────────────────────
func _make_static_word(text: String) -> Label:
	var lbl = Label.new()
	lbl.text = text
	#lbl.add_theme_font_size_override("font_size", 22)
	#lbl.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(0, 48)
	return lbl

# ─────────────────────────────────────────────
#  FACTORY : DropSlot
# ─────────────────────────────────────────────
func _make_drop_slot(idx: int) -> Control:
	var slot = preload("res://DragNdropSystem/DropSlot.gd").new()
	slot.slot_index = idx
	slot.custom_minimum_size = Vector2(100, 48)
	slot.word_dropped.connect(_on_word_dropped_in_slot)
	return slot

# ─────────────────────────────────────────────
#  FACTORY : WordCard (mot draggable)
# ─────────────────────────────────────────────
func _make_word_card(word: String) -> Control:
	var card = preload("res://DragNdropSystem/WordCard.gd").new()
	card.word_text = word
	card.custom_minimum_size = Vector2(80, 44)
	return card

# ─────────────────────────────────────────────
#  SIGNAL : un mot est posé dans un slot
# ─────────────────────────────────────────────
func _on_word_dropped_in_slot(card, slot):
	# Si le slot avait deja un mot -> le remettre visible dans le word bank
	if slot.current_card != null and slot.current_card != card:
		slot.current_card.visible = true
		slot.release_card()

	# Si la carte vient d'un autre slot -> liberer cet ancien slot
	for s in drop_slots:
		if s != slot and s.current_card == card:
			s.release_card()

	# Le slot affiche le mot directement (pas de reparent)
	slot.current_card = card
	slot.placed_word = card.word_text
	slot.queue_redraw()
	# Cacher la carte originale dans le word bank
	card.visible = false

func _return_card_to_bank(card):
	card.visible = true

# ─────────────────────────────────────────────
#  VÉRIFICATION
# ─────────────────────────────────────────────
func _on_check():
	var data = phrases[current_phrase_index]
	var answers = data.answers
	var all_correct = true

	for i in drop_slots.size():
		var slot = drop_slots[i]
		if slot.current_card == null:
			all_correct = false
			slot.show_empty_error()
		elif slot.current_card.word_text == answers[i]:
			slot.show_correct()
		else:
			slot.show_incorrect()
			all_correct = false

	if all_correct:
		result_label.text = "🎉 Bravo, c'est correct !"
		#result_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		next_button.visible = current_phrase_index < phrases.size() - 1
		check_button.disabled = true
		# Dernière phrase complétée → succès global
		if current_phrase_index == phrases.size() - 1:
			success.emit()
			
	else:
		result_label.text = "❌ Pas tout à fait... Réessaie !"
		#result_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

# ─────────────────────────────────────────────
#  RESET / NEXT
# ─────────────────────────────────────────────
func _on_reset():
	_load_phrase(current_phrase_index)

func _on_next():
	current_phrase_index = (current_phrase_index + 1) % phrases.size()
	_load_phrase(current_phrase_index)

func exit_game() -> void:
	hide()
