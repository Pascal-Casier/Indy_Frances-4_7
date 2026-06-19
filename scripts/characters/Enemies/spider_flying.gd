extends Node3D

@export var rot_speed := 100.0
@onready var axis: Node3D = $axis

var time = 0
var original_position : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = axis.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	axis.rotation_degrees += Vector3(0, -rot_speed, 0) * delta
	
	axis.rotation_degrees.y += 30 * delta
	
	# Oscillation verticale
	time += delta
	position.y = original_position.y + (sin(time * PI) * 0.5)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
