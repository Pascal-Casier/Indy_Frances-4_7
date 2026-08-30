@tool
extends Node3D

@export var titre_fr : String
@export var son : AudioStream
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D/Label3D.text = titre_fr
	audio_stream_player.stream = son
	if Engine.is_editor_hint():
		mesh_instance_3d.show()
	else:
		mesh_instance_3d.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not son:
		return
	if event.is_action_pressed("interact") and mesh_instance_3d.visible:
		audio_stream_player.play()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		mesh_instance_3d.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		mesh_instance_3d.hide()
