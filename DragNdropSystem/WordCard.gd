extends Control
## Carte de mot draggable via le système natif de Godot 4

var word_text: String = "mot"

# Couleurs
const COLOR_BG       = Color("#502904")
const COLOR_BORDER   = Color("a7370e")
const COLOR_HOVER    = Color("a7370e")
const COLOR_TEXT     = Color(0.95, 0.92, 1.0)

var _hovered := false

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(func(): _hovered = true;  queue_redraw())
	mouse_exited.connect( func(): _hovered = false; queue_redraw())
	# Taille minimale adaptée au texte
	custom_minimum_size = Vector2(
		max(80, word_text.length() * 14 + 24),
		44
	)

# ─── Dessin custom ────────────────────────────
func _draw():
	var rect = Rect2(Vector2.ZERO, size)
	var _radius = 8.0
	var bg = COLOR_HOVER if _hovered else COLOR_BG
	# Fond arrondi
	draw_rect(rect.grow(-2), bg)  # simplifié (Godot 4 n'a pas draw_rounded_rect natif en API simple)
	# Bordure
	draw_rect(rect, COLOR_BORDER, false, 2.0)
	# Texte centré
	#var font = ThemeDB.fallback_font
	var font = get_theme_font("font", "Label")
	var font_size = get_theme_font_size("font_size", "Label")
	#var font_size = 18
	#var color_text = get_theme_color("font_color", "Label")
	var text_size = font.get_string_size(word_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = Vector2(
		(size.x - text_size.x) / 2.0,
		(size.y + text_size.y) / 2.0 - 4
	)
	draw_string(font, text_pos, word_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, COLOR_TEXT)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

# ─── Drag natif Godot 4 ───────────────────────
func _get_drag_data(_at_position: Vector2) -> Variant:
	# Créer la preview visuelle centrée sur la souris
	var preview = _make_preview()
	set_drag_preview(preview)
	return self   # on passe la référence à la carte elle-même

func _make_preview() -> Control:
	# Conteneur racine (taille nulle) — le Panel est décalé pour être centré sur le curseur
	var container = Control.new()

	var p = Panel.new()
	p.custom_minimum_size = size
	p.size = size
	# Décalage négatif de la moitié de la taille = centrage sur le curseur
	p.position = -size / 2.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.35, 0.28, 0.65, 0.9)
	style.border_color = Color(0.75, 0.6, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	p.add_theme_stylebox_override("panel", style)

	var lbl = Label.new()
	lbl.text = word_text
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	p.add_child(lbl)
	container.add_child(p)
	return container
