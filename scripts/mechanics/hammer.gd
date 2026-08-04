extends Node3D

@export var door_nbr : int = -1
@export var automatic : bool = false
@onready var sparks: GPUParticles3D = %sparks
@onready var flash: GPUParticles3D = %flash
@onready var fire: GPUParticles3D = %fire
@onready var smoke: GPUParticles3D = %smoke
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if not automatic:
		animation_player.stop()
	else:
		animation_player.play("strike")
	Global.open_door_gate.connect(_on_signal_emited)


func _on_signal_emited(nbr) ->void:
	if nbr == door_nbr:
		animation_player.play("hammer_down")
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
	if body.is_in_group("voiture"):
		if body.get_parent().has_method("appliquer_penalite"):
				body.get_parent().appliquer_penalite(0.3, 3.0)

func sparking()-> void:
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
