extends Node3D

@export var door_nbr : int = -1
@export var switch_id: String = "lift_01"
@export var turn_off : bool = true
var is_on : bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and %Label3D.visible:
		Global.emit_open_door_gate(door_nbr)
		if !is_on:
			%AnimationPlayer.play("on")
			is_on = true
		else:
			%AnimationPlayer.play("off")
			is_on = false
		Global.set_switch(switch_id, is_on)
		if turn_off:
			%Label3D.hide()
			%Area3D.set_deferred("monitoring", false)
		
