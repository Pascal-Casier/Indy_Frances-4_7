extends Area3D

signal pressedE

@onready var label_3d: Label3D = %Label3D
@onready var contour: MeshInstance3D = %contour
@export var doornbr : int = -10


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d.show()
		contour.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d.hide()
		contour.hide()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and label_3d.visible:
		pressedE.emit()
		Global.emit_open_door_gate(doornbr)
		$AudioStreamPlayer.play()
		call_deferred("set_monitoring", false)
