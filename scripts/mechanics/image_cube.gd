extends RigidBody3D

@export var image : Texture2D 
@export var letter : String = "test"
@export var highlight_material: StandardMaterial3D
@onready var crate = $Cube_Default
@onready var crate_material: StandardMaterial3D = crate.mesh.surface_get_material(0)

func _ready() -> void:
	for l in %labels.get_children():
		l.texture = image

func add_highlight() -> void:
	crate.set_surface_override_material(1, crate_material.duplicate())
	crate.get_surface_override_material(1).next_pass = highlight_material
	
func remove_highlight() -> void:
	crate.set_surface_override_material(0, null)

func _on_interactable_focused(_interactor):
	add_highlight()

func _on_interactable_interacted(_interactor):
	pass


# Called when the node enters the scene tree for the first time.

func get_letter() -> String:
	return letter
	
func set_letter(new_letter):
	letter = new_letter
