extends Node3D

@export var automatic : bool = false
@export var arrow_speed : float = 35
@export var cadence : float = 1.0
@onready var timer: Timer = $Timer
@onready var marker_3d: Marker3D = %Marker3D
@onready var arrow = preload("res://scenes/mechanics/arrow.tscn")
var is_active : bool = false
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = cadence
	if automatic:
		timer.start()

func set_cadence(_cadence: float) -> void:
	timer.wait_time = _cadence

func fire() -> void:
	var b = arrow.instantiate()
	# Ajoutez la flèche à la scène principale plutôt qu'au Marker3D
	get_tree().current_scene.add_child(b)
	
	# Positionnez la flèche à la position globale du Marker3D
	b.global_position = %Marker3D.global_position
	b.global_transform.basis = %Marker3D.global_transform.basis
	b.apply_central_impulse(%Marker3D.global_transform.basis.z * arrow_speed)
	audio_stream_player_3d.play()
	animation_player.play("fire")
	

func _on_body_entered(body: Node3D) -> void:
	if automatic:
		return
	if body.is_in_group("Player"):
		is_active = true
		timer.start()
		fire()


func _on_body_exited(body: Node3D) -> void:
	if automatic:
		return
	if body.is_in_group("Player"):
		is_active = false
		timer.stop()


func _on_timer_timeout() -> void:
	fire()
