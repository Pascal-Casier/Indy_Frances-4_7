extends RigidBody3D

@onready var label_3d = %Label3D
@onready var collision_shape = %CollisionShape3D
@onready var mesh_instance = %MeshInstance3D

var french_word: String = ""
var move_speed: float = 2.0
var move_direction: float = 1.0  # 1 = droite, -1 = gauche (float, plus Vector3)
var x_limit: float = 7.0

signal target_hit(word: String)

func _ready():
	# Pas de gravité, pas de rotation, déplacement uniquement sur X
	gravity_scale = 0.0
	lock_rotation = true
	axis_lock_linear_y = true
	axis_lock_linear_z = true
	linear_damp = 0.0
	randomize_balloon_color()
	body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	# Inverser la direction aux limites
	if position.x > x_limit and move_direction > 0:
		move_direction = -1.0
	elif position.x < -x_limit and move_direction < 0:
		move_direction = 1.0
	linear_velocity = Vector3(move_direction * move_speed, 0, 0)

func set_word(word: String):
	french_word = word
	label_3d.text = word

func _on_body_entered(body):
	if body.is_in_group("Bullet"):
		target_hit.emit(french_word)
		create_hit_effect()
		queue_free()

func emit_hit_signal() -> void:
	target_hit.emit(french_word)
	create_hit_effect()
	queue_free()

func create_hit_effect():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)

func randomize_balloon_color():
	# 1. Retrouver le matériau, où qu'il soit défini
	var base_mat: Material = mesh_instance.material_override
	var use_override := base_mat != null

	if base_mat == null:
		base_mat = mesh_instance.get_active_material(0)

	if base_mat == null:
		push_warning("Ballon : aucun matériau trouvé sur le MeshInstance3D")
		return

	if not (base_mat is BaseMaterial3D):
		push_warning("Ballon : le matériau n'est pas un StandardMaterial3D (type : %s)" % base_mat.get_class())
		return

	# 2. Copie unique pour ce ballon
	var mat := base_mat.duplicate() as BaseMaterial3D

	# 3. Nouvelle couleur en gardant l'alpha d'origine
	var alpha := mat.albedo_color.a
	mat.albedo_color = Color.from_hsv(randf(), 0.7, 1.0, alpha)

	# 4. Appliquer au bon endroit
	if use_override:
		mesh_instance.material_override = mat
	else:
		mesh_instance.set_surface_override_material(0, mat)
