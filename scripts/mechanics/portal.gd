extends Node3D

@export var next_scene : String
@export var next_level : int = 1


func _on_exit_mesh_body_entered(body):
	if body.is_in_group("Player"):
		Global.niveau_number = next_level
		body.hide()
		$CanvasLayer.show()
		$Exit_mesh/AnimationPlayer.play("fadeout")
		
func change_scene() -> void:
	Loader.chang_level(next_scene)
	#SceneLoader.load_scene(next_scene)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
