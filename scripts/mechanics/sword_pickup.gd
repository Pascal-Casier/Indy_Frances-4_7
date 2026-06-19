extends Area3D

@export_enum("sword", "parachute") var type
@onready var sword_rare: MeshInstance3D = $sword_rare

var speed : float = 2.0
var min_speed := 1.0
var max_speed := 3.0
var frequency = 2.0  # Vitesse du mouvement
var time = 0.0
var amplitude = 0.01  # Hauteur du mouvement
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer


func _ready() -> void:
	speed = randf_range(min_speed, max_speed)

func _process(delta: float) -> void:
	sword_rare.rotation_degrees.y += 50 * delta
	time += delta
	var offset = sin(time * frequency) * amplitude
	global_position.y = global_position.y + offset


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if type == 0:
			Global.has_sword.emit()
		elif type == 1:
			Global.can_glide = true
		%AudioStreamPlayer.play()
		sword_rare.hide()
		set_deferred("monitoring", false)
		await audio_stream_player.finished
		queue_free()
