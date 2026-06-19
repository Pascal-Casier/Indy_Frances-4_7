extends AnimatableBody3D

@export var automatic := true
@export var door_nbr := -1
@export var pos1 : Vector3
@export var pos2 : Vector3
@export var time = 3.0
@export var pause_time : float = 1.0


func _ready() -> void:
	Global.open_door_gate.connect(trigger)
	if automatic:
		move_platform()

func move_platform():
	var pos_initial = position
	var pos_final = position + pos2
	
	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_loops()
	tween.tween_property(self, "position", pos_final, time).set_delay(pause_time)
	tween.tween_property(self, "position", pos_initial, time).set_delay(pause_time)

func trigger(dnr):
	if dnr == door_nbr:
		move_platform()
