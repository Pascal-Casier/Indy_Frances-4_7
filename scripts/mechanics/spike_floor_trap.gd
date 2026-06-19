extends Node3D
@export var auto : bool = false
@export var interval : int = 3
@export var flash_speed : float = 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func _ready() -> void:
	animation_player.speed_scale = flash_speed
	timer.wait_time = interval
	if auto:
		timer.start()

func _on_timer_timeout() -> void:
	animation_player.play("spike")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	elif body.is_in_group("Enemy"):
		body.hit(100)


func _on_area_3_dsteping_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("flash")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "flash":
		animation_player.play("spike")
