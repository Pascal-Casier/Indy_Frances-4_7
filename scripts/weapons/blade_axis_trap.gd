extends Node3D

@export var speed : float = 0.3
@export var interval : float = 0.6
@onready var blade_axis: Node3D = $blade_axis1
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D



func _ready() -> void:
	start_rotation_loop()

func start_rotation_loop() -> void:
	var tween = create_tween()
	tween.set_loops() # boucle infinie

	# Rotation de 180° (relative, toujours dans le même sens)
	tween.tween_callback(audio_player.play)
	tween.tween_property(blade_axis, "rotation:y", deg_to_rad(180), speed).as_relative().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(interval)

	# Deuxième rotation de 180° (relative aussi)
	tween.tween_callback(audio_player.play)
	tween.tween_property(blade_axis, "rotation:y", deg_to_rad(180), speed).as_relative().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(interval)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
