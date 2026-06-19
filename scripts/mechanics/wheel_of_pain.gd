extends Node3D

@export var speed_multiplier : float = 1.0
@onready var hazard_saw: MeshInstance3D = $Hazard_Saw
var speed = 220
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.speed_scale = speed_multiplier
	
func _process(delta: float) -> void:
	hazard_saw.rotation_degrees.z += speed * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
