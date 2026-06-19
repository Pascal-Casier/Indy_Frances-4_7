extends Node3D

@export var autostart : bool = true
@export var anim_speed : float = 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = anim_speed
	if autostart: 
		start()
	else:
		animation_player.stop()
	
func start():
	animation_player.play("move")
