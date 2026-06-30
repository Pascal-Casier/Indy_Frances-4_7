@tool
extends Area3D

signal success(bool)
@export var correct : bool
@export var model: PackedScene :
	set(value):
		model = value
		_update_model()  # appelé dès que tu changes la valeur dans l'inspecteur
		
@export var nom : String :
	set(value):
		nom = value
		_update_label()
@onready var marker_3d: Marker3D = $Marker3D
@onready var label_3d: Label3D = $Label3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _update_label() -> void:
	# Attend que le nœud soit prêt (important en mode @tool)
	if not is_node_ready():
		await ready
	label_3d.text = nom
	
func _update_model() -> void:
	# Attend que le nœud soit prêt (important en mode @tool)
	if not is_node_ready():
		await ready

	# Supprime l'ancien modèle s'il existe
	for child in marker_3d.get_children():
		child.queue_free()

	# Instancie le nouveau
	if model:
		var instance = model.instantiate()
		marker_3d.add_child(instance)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("voiture"):
		if correct:
			success.emit(true)
			audio_stream_player.pitch_scale = 1.0
			audio_stream_player.play()
			if body.get_parent().has_method("appliquer_penalite"):
				body.get_parent().appliquer_penalite(1.3, 3.0)
		else:
			audio_stream_player.pitch_scale = 0.5
			audio_stream_player.play()
			success.emit(false)
			if body.get_parent().has_method("appliquer_penalite"):
				body.get_parent().appliquer_penalite(0.3, 3.0)
