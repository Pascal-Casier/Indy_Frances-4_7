extends MeshInstance3D

signal word_found(mot)

@export var mot : String
@export var palavra: String
@export var categorie : String
@export var sound : AudioStream
@export var float_amplitude := 0.2
@export var float_speed := 1.0
var base_y := 0.0
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@export_color_no_alpha var couleur


func _ready() -> void:
	%Label3D.text = mot
	%Label3D.modulate = couleur
	base_y = global_position.y
	
func _process(_delta: float) -> void:
	global_position.y = base_y + sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_amplitude

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.ajouter_mot(mot)
		$Area3D.set_deferred("monitoring", false)
		audio_stream_player.stream = sound
		audio_stream_player.play()
		$AnimationPlayer.play("fade")
		_on_word_collected()
		
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	word_found.emit(mot)
	queue_free()

func _on_word_collected():
	Global.emit_signal("note_collected", 
		{mot: palavra}, 
		categorie
	)
