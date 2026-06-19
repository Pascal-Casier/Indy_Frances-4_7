extends CharacterBody3D

# === Paramètres ===
@export var jump_force: float = 8.0
@export var gravity: float = 20.0
@export var lane_tween_duration: float = 0.2

# Positions des 3 voies (X)
const LANES = [-2.0, 0.0, 2.0]
const LANE_LEFT  = 0
const LANE_CENTER = 1
const LANE_RIGHT  = 2

var current_lane: int = LANE_CENTER
var is_jumping: bool = false
var vertical_velocity: float = 0.0
var lane_tween: Tween

@onready var anim: AnimationPlayer = $IndianaJones_Model_4_2/AnimationPlayer

signal landed

func _ready() -> void:
	position.x = LANES[current_lane]
	anim.play("running")

#func _physics_process(delta: float) -> void:
	#print("on_floor: ", is_on_floor(), " | vel.y: ", velocity.y)
	## Gravité
	#if not is_on_floor():
		#vertical_velocity -= gravity * delta
	#else:
		#if is_jumping:
			#is_jumping = false
			#anim.play("running")
			#emit_signal("landed")
		#vertical_velocity = 0.0
#
	#velocity.y = vertical_velocity
	#move_and_slide()

func _physics_process(delta: float) -> void:
	# Appliquer la gravité si on n'est pas au sol
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		# Si on vient de toucher le sol après un saut
		if is_jumping and vertical_velocity <= 0:
			is_jumping = false
			anim.play("running")
			emit_signal("landed")
		
		# On garde une petite force vers le bas pour rester "collé" au sol 
		# et garantir que is_on_floor() reste vrai
		if not is_jumping:
			vertical_velocity = -0.1 

	velocity.y = vertical_velocity
	
	# Très important : move_and_slide utilise la vélocité du nœud
	move_and_slide()


func move_left() -> void:
	if current_lane > LANE_LEFT:
		current_lane -= 1
		_tween_to_lane()

func move_right() -> void:
	if current_lane < LANE_RIGHT:
		current_lane += 1
		_tween_to_lane()

func jump() -> void:
	if is_on_floor() and not is_jumping:
		is_jumping = true
		vertical_velocity = jump_force
		anim.play("jump")

func _tween_to_lane() -> void:
	if lane_tween:
		lane_tween.kill()
	lane_tween = create_tween()
	lane_tween.set_ease(Tween.EASE_OUT)
	lane_tween.set_trans(Tween.TRANS_CUBIC)
	lane_tween.tween_property(
		self, "position:x",
		LANES[current_lane],
		lane_tween_duration
	)
