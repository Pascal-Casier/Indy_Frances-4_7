extends Area3D

@export var letter : String = "A"
@onready var label_3d: Label3D = %Label3D
@onready var label_3d_2: Label3D = %Label3D2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var speed := 25


func _ready() -> void:
	label_3d.text = letter
	label_3d_2.text = letter


func _process(delta: float) -> void:
	rotation_degrees.y += speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		audio_stream_player.play()
		animation_player.play("picked")
		await animation_player.animation_finished
		Global.letter_picked_up.emit(letter)
		queue_free()
