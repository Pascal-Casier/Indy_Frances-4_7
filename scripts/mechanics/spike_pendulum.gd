extends Node3D

@onready var spiky_ball_2: RigidBody3D = $SpikyBall2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spiky_ball_2.apply_central_force(Vector3(500,0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
