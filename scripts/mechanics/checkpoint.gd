extends Area3D
class_name Checkpoint

@export var checkpoint_id: String = ""
@export var respawn_offset: Vector3 = Vector3(0, 1, 0)
@export var activation_sound: AudioStream
@export var visual_feedback: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var is_activated: bool = false
var audio_player: AudioStreamPlayer3D

func _ready():
	# Connexion du signal pour détecter le joueur
	body_entered.connect(_on_body_entered)
	
	# Création du lecteur audio
	audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)
	
	# Si pas d'ID défini, utiliser la position comme ID unique
	if checkpoint_id.is_empty():
		checkpoint_id = str(global_position)

func _on_body_entered(body):
	if body.is_in_group("Player") and not is_activated:
		activate_checkpoint()
		animation_player.play("show")
		

func activate_checkpoint():
	is_activated = true
	
	# Enregistrer ce checkpoint comme actif
	CheckpointManager.set_active_checkpoint(self)
	
	# Feedback visuel
	show_activation_feedback()
	
	# Feedback sonore
	if activation_sound:
		audio_player.stream = activation_sound
		audio_player.play()


func show_activation_feedback():
	# Animation simple ou effet de particules
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.2, 1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.2)

func get_respawn_position() -> Vector3:
	return global_position + respawn_offset
