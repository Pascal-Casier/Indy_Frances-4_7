extends Node3D

@export var door_nbr: int = -1
@export var is_up_at_start: bool = true
@export var auto_down := false
@export var time_to_down := 4.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var auto_down_timer: Timer = Timer.new()

var up := false
var can_operate: bool = true

func _ready():
	Global.open_door_gate.connect(open_door)
	add_child(auto_down_timer)
	auto_down_timer.one_shot = true
	auto_down_timer.wait_time = time_to_down
	auto_down_timer.timeout.connect(_on_auto_down_timeout)

	up = is_up_at_start
	animation_player.play("up" if is_up_at_start else "down")
	if is_up_at_start:
		animation_player.advance(1000)

func open_door(nbr: int) -> void:
	if nbr != door_nbr or not can_operate:
		return
	auto_down_timer.stop()
	if not up:
		_go_up()
	else:
		_go_down()

func _go_up() -> void:
	can_operate = false
	up = true
	animation_player.play("up")
	await animation_player.animation_finished
	can_operate = true
	if auto_down:
		auto_down_timer.start()

func _go_down() -> void:
	can_operate = false
	up = false
	animation_player.play("down")
	await animation_player.animation_finished
	can_operate = true

func _on_auto_down_timeout() -> void:
	if up and can_operate:
		_go_down()
		
		
