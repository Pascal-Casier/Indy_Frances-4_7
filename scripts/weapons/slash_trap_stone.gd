extends Node3D
class_name SlashTrap

@export var automatic : bool = false
@export var interval : float = 2.0

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_3d_trigger: Area3D = $Area3DTrigger

func _ready() -> void:
	if automatic: 
		timer.wait_time = interval
		timer.start()
	else:
		area_3d_trigger.monitoring = true

func _on_timer_timeout() -> void:
	animation_player.play("slash")


func _on_area_3_dhurt_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
		


func _on_area_3d_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("slash")
		
