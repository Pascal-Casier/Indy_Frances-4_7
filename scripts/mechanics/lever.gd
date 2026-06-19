extends Node3D

@export var door_nbr : int = 0
@export var turn_off : bool = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and %Label3D.visible:
		%AnimationPlayer.play("Lever_On")
		%AudioStreamPlayer.play()
		Global.emit_open_door_gate(door_nbr)
		if turn_off:
			%Label3D.hide()
			%Area3D.set_deferred("monitoring", false)
		
