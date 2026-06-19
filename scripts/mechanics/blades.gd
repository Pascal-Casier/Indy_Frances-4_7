extends StaticBody3D

@export var is_on : bool = true
@export var speed : float = 3.5
#@export var door_number : int = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not is_on:
		set_process(false)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(-speed * delta)


func _on_blades_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and body.has_method("damage_received"):
		body.damage_received()
