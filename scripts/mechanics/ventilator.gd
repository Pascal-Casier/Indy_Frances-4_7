extends Node3D

@export var is_on := false
@export var door_nbr := -1
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	Global.open_door_gate.connect(open_door)
	if is_on:
		animation_player.play("on")
		$GPUParticles3D.emitting = true
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.is_in_ventilator = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.is_in_ventilator = false

func open_door(index : int) ->void:
	if index == door_nbr:
		turn_on_off()

func turn_on_off():
	if animation_player.is_playing():
		animation_player.stop()
		$GPUParticles3D.emitting = false
	else:
		animation_player.play("on")
		$GPUParticles3D.emitting = true
		
