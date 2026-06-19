extends Node3D

@onready var dictionnary_panel: DictionnaryPanel = %DictionnaryPanel


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().paused = true
		dictionnary_panel.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
