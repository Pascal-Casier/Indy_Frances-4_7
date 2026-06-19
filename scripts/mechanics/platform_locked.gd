extends Node3D

@export var door_nbr: int = -1
@export var is_up_at_start : bool = true
@export var auto_down := false
@export var time_to_down := 4.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var up := false
var object :RigidBody3D = null

func _ready():
	Global.open_door_gate.connect(open_door)
	if is_up_at_start:
		#animation_player.play("up")
		up = true
		
	else : 
		animation_player.play("down")

func open_door(nbr):
	if object:
		object.sleeping = false
		object.apply_central_impulse(Vector3(0, 1, 0))
	if nbr == door_nbr and !up:
		animation_player.play("up")
		await animation_player.animation_finished
		up = true
		if auto_down:
			await get_tree().create_timer(time_to_down).timeout
			auto_go_down()
	elif nbr == door_nbr and up:
		animation_player.play("down")
		await animation_player.animation_finished
		up = false

func auto_go_down() -> void:
	animation_player.play("down")
	
	await animation_player.animation_finished
	up = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D :
		object = body
		
		
		
		
