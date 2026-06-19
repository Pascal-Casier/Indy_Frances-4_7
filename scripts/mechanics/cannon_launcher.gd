extends Node3D

@export var auto_start : bool = true
@onready var marker_3d: Marker3D = %Marker3D
@export var speed := 130.0
@export var rate := 2.0
@export var door_nbr : int = -1
var can_shoot : bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

@onready var cannon_ball = preload("res://scenes/mechanics/spiky_ball_trap.tscn")

func _ready() -> void:
	timer.wait_time = rate
	if auto_start and can_shoot:
		timer.start()
	else:
		Global.open_door_gate.connect(_on_open_door)
	
func _process(_delta: float) -> void:
	pass
		
		
func shoot(delta) -> void:
	var b = cannon_ball.instantiate() as RigidBody3D
	marker_3d.add_child(b)
	b.global_position = marker_3d.global_position
	b.apply_central_impulse(marker_3d.global_transform.basis.x * speed * 1000 * delta)
	can_shoot = false
	
	animation_player.play("fire")
	await animation_player.animation_finished
	can_shoot = true


func _on_timer_timeout() -> void:
	shoot(get_process_delta_time())

func _on_open_door(nbr) -> void:
	if nbr == door_nbr:
		timer.start()
