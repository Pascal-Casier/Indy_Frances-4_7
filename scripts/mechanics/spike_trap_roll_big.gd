extends Node3D

@onready var spike_roller: MeshInstance3D = $spikeRoller_gltf/spikeRoller
var speed := 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	spike_roller.rotation_degrees.y += speed * delta


func _on_spike_roller_gltf_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
