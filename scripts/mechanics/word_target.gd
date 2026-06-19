extends RigidBody3D

@onready var label_3d = %Label3D
@onready var collision_shape = %CollisionShape3D
@onready var mesh_instance = %MeshInstance3D

var french_word: String = ""
var move_speed: float = 2.0
var move_direction: Vector3

signal target_hit(word: String)

func _ready():
	# Mouvement aléatoire
	move_direction = Vector3(
		randf_range(-1, 1),
		randf_range(-0.5, 0.5),
		0
	).normalized()
	
	# Connecter le signal de collision
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# Déplacer la cible
	position += move_direction * move_speed * delta
	
	# Inverser la direction si on sort des limites
	if abs(position.x) > 7:
		move_direction.x *= -1
	if position.y > 4 or position.y < 0.5:
		move_direction.y *= -1

func set_word(word: String):
	french_word = word
	label_3d.text = word

func _on_body_entered(body):
	# Vérifier si c'est un projectile
	if body.is_in_group("Bullet"):
	#if body.has_method("is_projectile"):
		target_hit.emit(french_word)
		# Effet visuel de destruction
		create_hit_effect()
		queue_free()

func emit_hit_signal() -> void:
	target_hit.emit(french_word)
		# Effet visuel de destruction
	create_hit_effect()
	queue_free()
	
func create_hit_effect():
	# Créer un effet de particules simple
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
