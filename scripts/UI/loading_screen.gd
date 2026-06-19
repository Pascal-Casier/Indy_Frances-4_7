extends Control

@export var textures: Array[Texture2D]
@export var tips : Array[String]

@onready var bgd: TextureRect = $bgd


func _ready() -> void:
	if textures.size() > 0:
		bgd.texture = textures.pick_random()
		
func _on_button_pressed():
	SceneLoader.change_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_visibility_changed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
