extends Node3D

signal on_letter_found

@export var letter_to_find : String = "a"
@export var show_sign : bool = true
@onready var label_3d_letter: Label3D = %Label3DLetter

var cube

func _ready() -> void:
	if show_sign:
		label_3d_letter.text = letter_to_find
		label_3d_letter.show()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("LetterCube"):
		if body.has_method("get_letter"):
			if body.get_letter() == letter_to_find:
				%Area3D.set_deferred("monitoring", false)
				%AnimationPlayer.play("correct")
				%Label3DLetter.text = letter_to_find
				%Label3DLetter.show()
				emit_signal("on_letter_found", letter_to_find)
			else:
				cube = body
				%AnimationPlayer.play("incorrect")
		
