extends Control


func _ready() -> void:
	%ColorRect.hide()

func _on_button_commencer_pressed() -> void:
	%AnimationPlayer.play("fadeout")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	Loader.chang_level("res://scenes/levels/landscape_4.tscn")
	
