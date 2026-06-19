extends AnimatableBody3D

@export var switch_id: String = "lift_01"  # doit correspondre
@export var door_nbr : int = -1
@export var move_distance: float = 5.0
@export var move_duration: float = 1.5
@export var move_direction: Vector3 = Vector3.UP
@export var callable_by_switch : bool = false
@export var auto_come_back : bool = false
@export var auto_come_back_delay: float = 2.0  # délai avant le retour

@onready var label_3d: Label3D = $Label3D
@onready var area_3d: Area3D = $Area3D
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $SM_PROP_lever_dungeon_01/AnimationPlayer

const LIFT_START = preload("res://assets/sounds/sfx/lift_start.mp3")

var player_inside: bool = false
var is_moving: bool = false
var is_at_top: bool = false
var origin_position: Vector3

func _ready() -> void:
	origin_position = global_position
	label_3d.visible = false
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)
	Global.switch_changed.connect(_on_switch_changed)
	Global.open_door_gate.connect(_on_doornbr_signal_recieved)
	

func _unhandled_input(event: InputEvent) -> void:
	if player_inside and not is_moving:
		if event.is_action_pressed("interact"):
			animation_player.play("pull_lever")
			_activate_elevator()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_inside = true
		label_3d.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		label_3d.visible = false

func _activate_elevator() -> void:
	is_moving = true
	label_3d.visible = false
	audio_stream_player.stream = LIFT_START
	audio_stream_player.play()

	var target_position: Vector3
	if is_at_top:
		target_position = origin_position
	else:
		target_position = origin_position + move_direction.normalized() * move_distance

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target_position, move_duration)
	tween.tween_callback(_on_tween_finished)

func _on_tween_finished() -> void:
	is_at_top = not is_at_top
	is_moving = false
	if player_inside:
		label_3d.visible = true
	# Si auto_come_back est activé ET que l'ascenseur n'est pas à l'origine, on programme le retour
	if auto_come_back and is_at_top:
		await get_tree().create_timer(auto_come_back_delay).timeout
		if not is_moving:  # sécurité : le joueur n'a pas re-déclenché manuellement entre temps
			_activate_elevator()

func _on_switch_changed(id: String, _is_on: bool) -> void:
	if id != switch_id:
		return
	if is_moving or !callable_by_switch:
		return
	_activate_elevator()
		
func _on_doornbr_signal_recieved(door_nr : int) -> void:
	if door_nbr == door_nr:
		_activate_elevator()
