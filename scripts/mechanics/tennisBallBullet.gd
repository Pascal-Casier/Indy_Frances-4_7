extends RigidBody3D

@export var kill :=true
@export var kill_time := 5
@onready var sphere: MeshInstance3D = $Sphere
@onready var sphere_material: StandardMaterial3D = sphere.mesh.surface_get_material(0)

func _ready() -> void:
	if kill:
		await get_tree().create_timer(kill_time).timeout
		queue_free()
		
func _on_interactable_focused(_interactor: Interactor) -> void:
	$CanvasLayer.show()
	%contour.show()

func _on_interactable_unfocused(_interactor: Interactor) -> void:
	$CanvasLayer.hide()
	%contour.hide()


func _on_interactable_interacted(_interactor: Interactor) -> void:
	pass # Replace with function body.

func add_highlight():
	pass

func remove_highlight():
	pass
