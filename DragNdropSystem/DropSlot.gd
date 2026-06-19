extends Control
## Zone de dépôt pour un mot manquant (trou dans la phrase)
## Le slot stocke le mot déposé et le dessine directement — plus fiable que reparenter

signal word_dropped(card: Control, slot: Control)

var slot_index: int = 0
var current_card: Control = null   # référence gardée pour pouvoir le remettre au bank
var placed_word: String = ""       # le texte affiché dans le slot

# États visuels
enum State { IDLE, HOVER, CORRECT, INCORRECT, EMPTY_ERROR }
var _state: State = State.IDLE

#const COLOR_IDLE       = Color(0.18, 0.16, 0.30)
const COLOR_IDLE = Color("#502904")
const COLOR_BORDER     = Color(0.45, 0.38, 0.70, 0.8)
const COLOR_HOVER      = Color(0.28, 0.22, 0.50)
const COLOR_HOVER_BD   = Color(0.75, 0.6, 1.0)
const COLOR_CORRECT    = Color(0.15, 0.45, 0.25)
const COLOR_CORRECT_BD = Color(0.3, 1.0, 0.5)
const COLOR_WRONG      = Color(0.45, 0.15, 0.18)
const COLOR_WRONG_BD   = Color(1.0, 0.35, 0.4)
const COLOR_ERROR_BD   = Color(1.0, 0.7, 0.2)
const COLOR_TEXT       = Color(0.95, 0.92, 1.0)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(100, 48)

# ─── Dessin ──────────────────────────────────
func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var bg: Color
	var border: Color

	match _state:
		State.HOVER:
			bg = COLOR_HOVER;      border = COLOR_HOVER_BD
		State.CORRECT:
			bg = COLOR_CORRECT;    border = COLOR_CORRECT_BD
		State.INCORRECT:
			bg = COLOR_WRONG;      border = COLOR_WRONG_BD
		State.EMPTY_ERROR:
			bg = COLOR_IDLE;       border = COLOR_ERROR_BD
		_:
			bg = COLOR_IDLE;       border = COLOR_BORDER

	draw_rect(rect.grow(-2), bg)
	draw_rect(rect, border, false, 2.0)

	var font = ThemeDB.fallback_font
	var fs = 18

	if placed_word != "":
		# Afficher le mot placé
		var ts = font.get_string_size(placed_word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
		var pos = Vector2((size.x - ts.x) / 2.0, (size.y + ts.y) / 2.0 - 4)
		draw_string(font, pos, placed_word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, COLOR_TEXT)
	else:
		# Afficher le tiret indicateur
		var hint = "___"
		var ts = font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		var pos = Vector2((size.x - ts.x) / 2.0, (size.y + ts.y) / 2.0 - 4)
		draw_string(font, pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, border)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

# ─── Drop natif Godot 4 ──────────────────────
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Control and data.has_method("_get_drag_data"):
		_state = State.HOVER
		queue_redraw()
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	_state = State.IDLE
	queue_redraw()
	word_dropped.emit(data, self)

# ─── Feedback visuel depuis Main ─────────────
func show_correct():
	_state = State.CORRECT
	queue_redraw()

func show_incorrect():
	_state = State.INCORRECT
	queue_redraw()

func show_empty_error():
	_state = State.EMPTY_ERROR
	queue_redraw()

func release_card():
	current_card = null
	placed_word = ""
	_state = State.IDLE
	queue_redraw()
