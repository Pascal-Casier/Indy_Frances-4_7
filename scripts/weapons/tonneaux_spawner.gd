extends Node3D

@export var obstacle_scene: PackedScene
@export var automatic_start : bool = true
@export var impulse_force : int = 500
@export var spawn_timer : float = 1.0
@export var door_nbr : int = -1
@export var angle_max: float = 30.0   # amplitude en degrés
@export var speed: float = 1.5        # vitesse d'oscillation

@onready var timer: Timer = $Timer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var marker_3d: Marker3D = %Marker3D

var time: float = 0.0

func _ready() -> void:
	#$MeshInstance3D.hide()
	timer.wait_time = spawn_timer
	if automatic_start:
		timer.start()
	else:
		Global.open_door_gate.connect(triggered)

func _process(delta):
	time += delta
	# Oscillation sur l'axe Y
	var angle = deg_to_rad(angle_max) * sin(time * speed)
	marker_3d.rotation.y = angle

func triggered(door) -> void:
	if door == door_nbr:
		spawn_obstacle()
		timer.start()
		audio_stream_player_3d.play()
		
func spawn_obstacle():	
	var obstacle = obstacle_scene.instantiate()
	get_tree().current_scene.add_child(obstacle)
	obstacle.global_position = marker_3d.global_position
	obstacle.global_transform.basis = marker_3d.global_transform.basis
	# L'obstacle hérite de la direction du spawner au moment du spawn
	obstacle.apply_central_impulse(-marker_3d.global_transform.basis.z * impulse_force)


func _on_timer_timeout() -> void:
	spawn_obstacle()
