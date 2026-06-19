extends Node3D

@export var doornbr : int = -1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var is_open : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.open_door_gate.connect(rotate_door)

func rotate_door(nbr) -> void:
	if nbr == doornbr and !is_open:
		animation_player.play("rotate")
		is_open = true
