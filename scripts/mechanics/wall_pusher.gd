extends Node3D

@export var interval : float = 2.0
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cube: MeshInstance3D = $crushing_wall/Cube


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = interval


func _on_timer_timeout() -> void:
	animation_player.play("crush")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	elif body.is_in_group("Enemy"):
		body.hit(100)
