extends Area3D

@onready var bear_trap_open: MeshInstance3D = $BearTrap_Open
@onready var bear_trap_closed: MeshInstance3D = $BearTrap_Closed
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var is_triggered : bool = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Pickeable"):
		trigger()
		if body.is_in_group("Player") and body.has_method("damage_received"):
			body.damage_received()
		
func trigger() -> void:
	if is_triggered:
		return
	await get_tree().create_timer(0.1).timeout
	audio_stream_player_3d.play()
	bear_trap_closed.show()
	bear_trap_open.hide()
	for s in %explosion.get_children():
		if s is GPUParticles3D:
			s.emitting = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	is_triggered = true

func hit(_hit_nbr : int)-> void:
	trigger()
