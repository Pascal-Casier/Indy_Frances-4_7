extends Node3D

signal correct
@export var letter_to_find : String = "a"
var _correct := false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("LetterCube"):
		if body.has_method("get_letter"):
			if body.get_letter() == letter_to_find:
				%AnimationPlayer.play("correct")
				_correct = true
				emit_signal("correct", letter_to_find)
				
			else:
				%AnimationPlayer.play("eject")
				await get_tree().create_timer(1).timeout
				body.apply_central_impulse(Vector3(0, 820, 100))
