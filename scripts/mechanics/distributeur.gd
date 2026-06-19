extends Node3D

@export var max_number : int = 5
@onready var lbl_nbr: Label3D = %lblNbr
@onready var lbl_press_e: Label3D = %lblPressE
@onready var marker_3d: Marker3D = %Marker3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var ball : PackedScene

func _ready() -> void:
	lbl_nbr.text = str(max_number)
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and lbl_press_e.visible and max_number > 0:
		audio_stream_player.play()
		animation_player.play("spawn")
		var b = ball.instantiate()
		b.position = marker_3d.global_position
		get_tree().get_root().add_child(b)
		max_number -=1
		lbl_nbr.text = str(max_number)




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.hide()
