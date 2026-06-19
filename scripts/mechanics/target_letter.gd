extends Node3D


@export var lettre: String
signal cible_touchee(lettre: String)
@onready var label_3d: Label3D = %Label3D

func _ready() -> void:
	label_3d.text = lettre
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Pickeable"):
		$AudioStreamPlayer.play()
		%AnimationPlayer.play("bullseye")
		cible_touchee.emit(lettre)
