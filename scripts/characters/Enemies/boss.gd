extends Enemy

const simple_attacks := {
	'slice' : "2H_Melee_Attack_Slice",
	'spin' : "2H_Melee_Attack_Spin",
	'range' : "1H_Melee_Attack_Stab"
}

@export var spin_speed := 6.0
var spinning := false
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
const ZOMBIE_GROAN = preload("res://assets/sounds/sfx/Zombie groan.mp3")
const MUTANTDIE = preload("res://assets/sounds/sfx/mutantdie.wav")

func _ready() -> void:
	audio_stream_player_3d.stream = ZOMBIE_GROAN
	audio_stream_player_3d.pitch_scale = 0.5
	audio_stream_player_3d.play()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += -gravity * delta
	else:
		velocity.y = 0
	move_to_player(delta)
	

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
	if position.distance_to(player.position) < 5.0:
		melee_attacke_animation()
	else:
		if rng.randi() % 2:
			range_attack_animation()
		else:
			spin_attack_animation()

func spin_attack_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed", spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	$Timers/AttackTimer.stop()
	spinning = true

func _spin_transition(value: float) -> void:
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)
func range_attack_animation() -> void:
	stop_movement(1.5, 1.5)
	attack_animation.animation = simple_attacks['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func melee_attacke_animation() -> void:
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
	
	if spinning:
		var tween = create_tween()
		tween.tween_property(self, "speed", walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		spinning = false
		$Timers/AttackTimer.start()

func hit() -> void:
	if not $Timers/InvulTimer.time_left:
		audio_stream_player_3d.stream = MUTANTDIE
		audio_stream_player_3d.play()
		$Timers/InvulTimer.start()

func die():
	queue_free()
	
func _on_invul_timer_timeout() -> void:
	audio_stream_player_3d.stream = ZOMBIE_GROAN
	audio_stream_player_3d.play()
