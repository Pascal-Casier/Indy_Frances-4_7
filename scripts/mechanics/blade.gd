extends Node3D

@onready var hazard_saw: MeshInstance3D = %Hazard_Saw

var speed : float = 800
@export var door_nbr : int = -1
@export var target_position: Vector3 = Vector3(10, 0, 5)

# Paramètres du déplacement
@export var offset1: Vector3 = Vector3(-5, 0, -5)
@export var offset2: Vector3 = Vector3(5, 0, -5)
@export var offset3: Vector3 = Vector3(5, 0, 5)
@export var offset4: Vector3 = Vector3(-5, 0, 5)

@export var movement_duration: float = 2.0
@export var auto_start: bool = true
@export var loop: bool = true

var initial_position: Vector3

func _ready():
	initial_position = position
	Global.open_door_gate.connect(_on_doornbr_signal_received)
	if auto_start:
		move_in_square()

func _on_doornbr_signal_received(doornbr:int) -> void:
	if doornbr == door_nbr:
		move_in_square()

func move_in_square():
	var tween = create_tween()
	
	if loop:
		tween.set_loops()
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Appliquer les offsets à la position initiale
	tween.tween_property(self, "position", initial_position + offset1, movement_duration)
	tween.tween_property(self, "position", initial_position + offset2, movement_duration)
	tween.tween_property(self, "position", initial_position + offset3, movement_duration)
	tween.tween_property(self, "position", initial_position + offset4, movement_duration)

func _process(delta: float) -> void:
	hazard_saw.rotation_degrees.x += speed * delta
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	elif body.is_in_group("Enemy"):
		body.hit(100)
