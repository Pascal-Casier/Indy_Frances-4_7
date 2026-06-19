extends Node3D

@export var door_nbr: int = 0
@onready var cube: MeshInstance3D = %Cube

var is_open := false

func _ready():
	Global.open_door_gate.connect(open_door)

func open_door(nbr):
	if nbr == door_nbr and !is_open:
		var tween = create_tween()
		var start_rotation = cube.rotation_degrees
		var end_rotation = start_rotation + Vector3(90, 0, 0)
		tween.tween_property(cube, "rotation_degrees", end_rotation, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE) # 1.0 seconde
		$AudioStreamPlayer.play()
		is_open = true
