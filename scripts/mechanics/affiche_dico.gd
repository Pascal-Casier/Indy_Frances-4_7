extends Node3D

@export var nom : String = "un chien"
@export var nomBR : String
@export var ico : Texture2D
@export var son : AudioStream


@export var categorie : String

@onready var label_3d: Label3D = $MeshInstance3D/Label3D
@onready var sprite_3d_2: Sprite3D = $MeshInstance3D/Sprite3D2
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var lbl_port: Label3D = %LblPort

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = nom
	lbl_port.text = nomBR
	sprite_3d_2.texture = ico
	audio_stream_player.stream = son
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_port.show()
		_on_note_collected()
		if son:
			audio_stream_player.play()
		var tween = create_tween()
		#if tween:
			#tween.kill()
		tween.tween_property(label_3d, "scale", Vector3(1.2, 1.2, 1.2), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(label_3d, "scale", Vector3(1, 1, 1), 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
func _on_note_collected():
	Global.emit_signal("note_collected", 
		{nom: nomBR}, 
		categorie
	)
	Global.ajouter_mot(nom)
	
