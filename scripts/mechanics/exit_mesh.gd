extends Area3D

@export var next_scene : String

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SceneLoader.load_scene(next_scene)
		#get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
