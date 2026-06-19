extends Area3D

@export var word : String = "exemple"
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var label_3d: Label3D = $MeshInstance3D/Label3D

@onready var tween: Tween
var original_scale: Vector3

func _ready():
	label_3d.text = word
	original_scale = scale
	start_pulse_animation()

func start_pulse_animation():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_loops()
	
	# Pulsation de taille
	tween.tween_property(self, "scale", original_scale * 1.2, 0.7)
	tween.tween_property(self, "scale", original_scale * 0.95, 0.8)
	tween.tween_property(self, "scale", original_scale, 0.4)
	#tween.tween_interval(0.2)
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		audio_stream_player.play()
		set_deferred("monitoring", false)
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "scale", original_scale * 1.2, 0.7)
		tween.tween_property(self, "scale", original_scale * 0, 0.7)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		print_debug("nouveau mot")
		await tween.finished
		queue_free()
