extends Area3D

@export var note_title = "Titre de la note"
@export_multiline var note_content = "Contenu de la note"
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.add_note(note_title, note_content)
		audio_stream_player.play()
		canvas_layer.show()
		await get_tree().create_timer(1.3).timeout
		queue_free()
