extends Area3D

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var amplitude := 0.3
@export var speed := 2.0
@onready var mesh: MeshInstance3D = $Health

var start_y: float
var time := 0.0

func _ready():
	start_y = position.y

func _process(delta):
	time += delta
	mesh.position.y = start_y + sin(time * speed) * amplitude
	mesh.rotate_y(speed * delta)

func _on_body_entered(body: Node3D) -> void:
	if body.get_parent() is Jeep2:
		body.get_parent().heal()
		audio_stream_player_3d.play()
		await audio_stream_player_3d.finished
		queue_free()
