extends Node3D

@export var autostart : bool = true
@export var door_nb : int = -1
@export var anim_speed : float = 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.speed_scale = anim_speed
	Global.open_door_gate.connect(_on_door_nbr_received)
	if autostart: 
		start()
	else:
		animation_player.stop()

func _on_door_nbr_received(doornbr : int) -> void:
	if doornbr == door_nb:
		if animation_player.is_playing():
			stop()
		else:
			start()

func start():
	animation_player.play("move")
	$gun.show()
	$gun/Laser.enabled = true

func stop() -> void:
	animation_player.stop()
	$gun.hide()
	$gun/Laser.enabled = false
