extends Node3D

@export var speed : float = 1.0
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = speed
	pass
	
func _process(delta: float) -> void:
	%Hazard_Saw.rotation_degrees.x += delta * 500

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	elif body.is_in_group("Enemy"):
		body.hit(100)
