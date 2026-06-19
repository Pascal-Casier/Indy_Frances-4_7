extends Area3D

@export var is_battery :bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	rotation_degrees.y += 50 * delta


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_deferred("monitoring", false)
		if not is_battery:
			Global.can_light = true
		elif is_battery:
			Global.can_light = true
			Global.full_battery.emit()
		animation_player.play("picked")
		audio_stream_player.play()
		await audio_stream_player.finished
		queue_free()
