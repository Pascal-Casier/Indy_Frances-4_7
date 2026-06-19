extends Node3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var rope_2: MeshInstance3D = %Rope_2
@onready var canvas_layer: CanvasLayer = %CanvasLayer
var player = null

func _ready() -> void:
	canvas_layer.hide()
	
func _process(delta: float) -> void:
	rope_2.rotation_degrees.y += 200 * delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		body.has_found_whip = true
		audio_stream_player.play()
		animation_player.play("pickedup")
		await audio_stream_player.finished
		on_pause()
		
		#queue_free()
func on_pause() -> void:
	get_tree().paused = true
	player.can_move = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	canvas_layer.show()

func _on_button_ok_pressed() -> void:
	get_tree().paused = false
	player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()
