extends Node3D

#@export var start_time : float = 2.0
@export var waiting_time : float = 2.0
@export var anim_speed : float = 1.0

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = anim_speed
	timer.wait_time = waiting_time

func _on_timer_timeout() -> void:
	animation_player.play("flip")

func _on_start_timer_timeout() -> void:
	timer.start()
