extends Node3D

@export var door_number : int = -1
@export var switch_id : String = "door_01"
@export var anim_speed := 1.0
@export var close_after_open : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var open := false
var is_moving : bool = false

func _ready() -> void:
	
	Global.open_door_gate.connect(open_big_gate)
	Global.switch_changed.connect(_on_switch_changed)
	
func open_big_gate(nb) ->void:
	if is_moving:
		return
	if door_number == nb and not open:
		animation_player.speed_scale = 1.0
		animation_player.play("open_gate")
		open = true
		is_moving = true
	elif door_number == nb and open:
		closing()
		is_moving = true

func closing() -> void:
	animation_player.speed_scale = anim_speed
	animation_player.play("close_gate")
	open = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	is_moving = false
	if anim_name == "open_gate" and close_after_open:
		closing()
		
func _on_switch_changed(id: String, _is_on: bool) -> void:
	if id != switch_id:
		return
	if is_moving:
		return
	if not open:
		animation_player.speed_scale = 1.0
		animation_player.play("open_gate")
		open = true
		is_moving = true
	else:
		closing()
		is_moving = true
