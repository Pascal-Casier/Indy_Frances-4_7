extends CharacterBody3D

@export var speed := 4.0
@export var damage_per_hit: int  = 20
 
@export var health : int = 100
var player = null
@export var player_path : NodePath

@export var drop_quantity : int = 3
@export var drop_item : PackedScene = preload("res://scenes/mechanics/coin.tscn")
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $"KayKit Animated Character2/AnimationPlayer"

@onready var eyes: Area3D = $Eyes
@onready var attack_range: Area3D = $attack_range
@onready var hit_area: Area3D = $"KayKit Animated Character2/KayKit Animated Character/Skeleton3D/HandRight/sword_common/Hit_area"

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_stream_player_3d_hit: AudioStreamPlayer3D = $AudioStreamPlayer3DHit

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var drop: Node3D = %Drop



################# knockback test #################

@export var knockback_force := 5
var knockback_duration = 0.2
var is_in_knockback = false
var knockback_timer = 0.0
#################################


func _ready() -> void:
	player = get_node(player_path)
	set_process(false)

func _process(_delta: float) -> void:
	#############
	#if is_in_knockback:
		#knockback_timer += _delta
		#if knockback_timer >= knockback_duration:
			#is_in_knockback = false
			#knockback_timer = 0.0
	#else:
		velocity = Vector3.ZERO
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		velocity = (next_nav_point - global_transform.origin).normalized() * speed
		
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		
		move_and_slide()


func _on_eyes_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_process(true)
		audio_stream_player_3d.play()
		animation_player.play("Run")

func hit():
	set_process(true)
	animation_player.play("Run")
	audio_stream_player_3d_hit.pitch_scale = 1
	audio_stream_player_3d_hit.play()
	
	progress_bar.show()
	if health > damage_per_hit:
		health -= damage_per_hit
		progress_bar.value = health
	else:
		progress_bar.hide()
		die()

func die():
	audio_stream_player_3d_hit.pitch_scale = 0.7
	audio_stream_player_3d_hit.play()
	audio_stream_player_3d.stop()
	set_process(false)
	disble_areas()
	animation_player.play("Defeat")
	drop.trigger_drop(drop_quantity, drop_item)
	
func vanish():
	set_process(false)
	animation_player.play("vanish")
	await animation_player.animation_finished
	queue_free()

func disble_areas():
	eyes.monitoring = false
	hit_area.monitoring = false
	attack_range.monitoring = false
	%CollisionShape3D.disabled = true

func _on_eyes_body_exited(_body: Node3D) -> void:
	if _body.is_in_group("Player"):
		set_process(false)
		audio_stream_player_3d.stop()
		animation_player.play("Idle")

func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("Attack(1h)")
		set_process(false)
		await get_tree().create_timer(1).timeout
		set_process(true)
	

func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("Run")
		


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()
		

###########################################

#func take_hit(attack_direction):
	#if not is_in_knockback:
		#is_in_knockback = true
		#var knockback_direction = -attack_direction.normalized()
		#velocity = knockback_direction * knockback_force
#
#func _on_hitbox_area_entered(area):
	#if area.is_in_group("player_attacks"):
		#var attack_direction = global_position - area.global_position
		#take_hit(attack_direction)

#func knockback(origin)-> void:
	#velocity += (global_transform.origin - origin).normalized() * knockback_force
	#velocity.y -= knockback_force
	#print("knocked")
	
