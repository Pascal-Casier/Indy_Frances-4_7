extends Node3D

@onready var label_3d_press_e: Label3D = %Label3DPressE
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_streamclic: AudioStreamPlayer = %AudioStreamclic


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d_press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d_press_e.hide()

func _unhandled_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("interact") and label_3d_press_e.visible:
		animation_player.play("open")
		audio_streamclic.play()
		%Area3D.call_deferred("set_monitoring", false)
		


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass
	#area_3d_sortie.call_deferred("set_monitoring", true)
	
