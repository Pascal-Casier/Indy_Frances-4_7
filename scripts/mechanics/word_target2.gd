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
