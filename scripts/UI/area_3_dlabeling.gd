extends Area3D

@export var nome : String = "test1"
@export var traduction : String = ""
@export var categorie : String
@export var som : AudioStream
@onready var contour: MeshInstance3D = $contour


@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
var collected : bool = false


func _ready() -> void:
	$Control/Panel/Label.text = nome
	

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$Control.show()
		contour.show()
		audio_stream_player.stream = som
		audio_stream_player.play()
		if not collected:
			_on_note_collected()
			collected = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		$Control.hide()
		contour.hide()

func _on_note_collected():
	Global.emit_signal("note_collected", 
		{nome: traduction}, 
		categorie
	)
	
