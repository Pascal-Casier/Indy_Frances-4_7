extends CanvasLayer

signal animation_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var is_transparent := false

func _ready() -> void:
	if is_transparent:
		animation_player.play("transparent")
	else:
		animation_player.play("fade_in")
		
func _fade_in() -> void:
	animation_player.play("fade_in")

func _fade_out() -> void:
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in" or anim_name == "fade_out":
		animation_finished.emit()
