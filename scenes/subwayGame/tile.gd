extends StaticBody3D

@onready var label_3d: Label3D = $Label3D
@onready var collision_area: Area3D = $ScoreArea   # Area3D enfant pour détecter le joueur

var is_avoir: bool = false
var verb_text: String = ""
var main_ref: Node
var already_scored: bool = false

# Couleurs
const COLOR_AVOIR  = Color(0.2, 0.8, 0.3)   # vert
const COLOR_OTHER  = Color(0.9, 0.3, 0.3)   # rouge
const COLOR_NEUTRAL = Color(0.85, 0.85, 0.85) # gris (avant révélation)

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func setup(verb: String, avoir: bool, main: Node) -> void:
	verb_text = verb
	is_avoir = avoir
	main_ref = main

func _ready() -> void:
	label_3d.text = verb_text
	label_3d.font_size = 48
	label_3d.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label_3d.double_sided = true

	# Couleur de la dalle
	var mat = StandardMaterial3D.new()
	mat.albedo_color = COLOR_NEUTRAL
	mesh_instance.set_surface_override_material(0, mat)

	# Révéler la couleur après un court délai (feedback visuel)
	# ou immédiatement selon ta préférence :
	_set_color()

	# Connecter l'Area3D
	collision_area.body_entered.connect(_on_body_entered)

func _set_color() -> void:
	var mat = mesh_instance.get_surface_override_material(0)
	if mat:
		mat.albedo_color = COLOR_AVOIR if is_avoir else COLOR_OTHER

func _on_body_entered(body: Node3D) -> void:
	if already_scored:
		return
	if body is CharacterBody3D:  # c'est le joueur
		if is_avoir:
			already_scored = true
			main_ref.add_point()
			_flash_score()
		else:
			# Le joueur a marché sur un verbe non-AVOIR → Game Over
			main_ref.trigger_game_over()

func _flash_score() -> void:
	var tween = create_tween()
	var mat = mesh_instance.get_surface_override_material(0)
	tween.tween_property(mat, "albedo_color", Color.WHITE, 0.1)
	tween.tween_property(mat, "albedo_color", COLOR_AVOIR, 0.1)
