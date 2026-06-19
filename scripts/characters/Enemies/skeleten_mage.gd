extends Enemy

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
const ZOMBIE_GROAN = preload("res://assets/sounds/sfx/Zombie groan.mp3")

func _ready() -> void:
	audio_stream_player_3d.stream = ZOMBIE_GROAN
	audio_stream_player_3d.play()
	attack_radius = 10.0
	
func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(1.2, 2.0)
	if position.distance_to(player.position) < attack_radius:
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func die():
	set_physics_process(false)
	$AnimationTree.set("parameters/DeathOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
