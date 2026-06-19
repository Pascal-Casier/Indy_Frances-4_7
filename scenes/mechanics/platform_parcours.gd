extends AnimatableBody3D

@export var points: Array[Node3D]
@export var speed: float = 2.0
@export var wait_time: float = 0.5
@export_group("Activation")
@export var activate_on_player: bool = false
@export var player_group: String = "Player"
@export_group("Bounce Effect")
@export var bounce_depth: float = 0.3       # Profondeur en mètres (30 cm)
@export var bounce_duration: float = 0.15   # Durée de l'enfoncement
@export var bounce_return: float = 0.25     # Durée du retour

var current_index := 0
var direction := 1
var is_moving := false
var origin_position: Vector3

func _ready():
	if points.size() < 2:
		return
	global_position = points[0].global_position
	origin_position = global_position
	current_index = 0
	direction = 1

	if activate_on_player:
		$Area3D.body_entered.connect(_on_body_entered)
	else:
		start_move()

func _on_body_entered(body):
	if body.is_in_group(player_group) and not is_moving:
		%AudioStreamPlayer.play()
		_bounce_then_start()

func _bounce_then_start():
	if is_moving:
		return

	is_moving = true

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# 👇 Enfoncement vers le bas
	tween.tween_property(self, "global_position",
		origin_position + Vector3.DOWN * bounce_depth,
		bounce_duration)

	# 👆 Retour à la position initiale
	tween.tween_property(self, "global_position",
		origin_position,
		bounce_return)

	# ▶️ Puis lancement du déplacement
	tween.tween_callback(move_to_next_point)

func start_move():
	if is_moving:
		return
	is_moving = true
	move_to_next_point()

func move_to_next_point():
	var next_index = current_index + direction

	if next_index >= points.size():
		direction = -1
		next_index = points.size() - 2
	elif next_index < 0:
		direction = 1
		next_index = 1

	# On met à jour l'origine pour les prochains rebonds éventuels
	origin_position = points[current_index].global_position

	var target_position = points[next_index].global_position
	var distance = global_position.distance_to(target_position)
	var duration = distance / speed

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target_position, duration)
	tween.tween_interval(wait_time)
	tween.finished.connect(_on_reached_point.bind(next_index))

func _on_reached_point(new_index):
	current_index = new_index
	move_to_next_point()
