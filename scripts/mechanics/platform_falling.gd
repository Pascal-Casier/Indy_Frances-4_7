
extends Node3D

@export var time_to_shake : float = 1.0 # durée avant le début du tremblement
@export var shaking_speed : float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func trigger_fall():
	animation_player.speed_scale = shaking_speed
	animation_player.play("shake")
	
func _on_area_3d_body_entered(_body: Node3D) -> void:
	await get_tree().create_timer(time_to_shake).timeout
	trigger_fall()
	
func _on_area_3d_body_exited(_body: Node3D) -> void:
	pass
