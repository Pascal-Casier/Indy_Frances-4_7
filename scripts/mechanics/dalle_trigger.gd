extends Area3D

@export var door_nbr : int = 0
@export var turn_off : bool = true
@export var time_to_up : float = 3.0
var is_down : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !is_down:
		animation_player.play("down")
		timer.start(time_to_up)
		is_down = true
		Global.emit_open_door_gate(door_nbr)


func _on_timer_timeout() -> void:
	animation_player.play("up")
	is_down = false
