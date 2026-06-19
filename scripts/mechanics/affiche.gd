extends Node3D

@export var nouvelle_image : Texture2D

func _ready() -> void:
	if nouvelle_image:
		$Sprite3D.texture = nouvelle_image
