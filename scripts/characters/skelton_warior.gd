extends CharacterBody3D

var player = null

var health = 100

@export var drop_quantity : int = 3
@export var drop_item : PackedScene = preload("res://scenes/mechanics/coin.tscn")

var state_machine

@export var player_path : NodePath
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var audio_stream_player_hit: AudioStreamPlayer = %AudioStreamPlayerHit
@onready var drop: Node3D = %Drop
@onready var health_bar_3d: Sprite3D = $HealthBar3D


const SPEED = 4.0
const ATTACK_RANGE := 2.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	

func _process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Running_A" : 
			#navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			#rotation.y = lerp(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
			
		"1H_Melee_Attack_Slice_Diagonal":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	###conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.set("parameters/playback", _target_in_range())
	
	#if health <= 0:
		#anim_tree.set("parameters/conditions/run", false)
		#anim_tree.set("parameters/conditions/attack", false)
		#die()
		
	move_and_slide()

func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		#var dir = global_position.direction_to(player.global_position)
		#player.knockback(dir)
		player.damage_received()
		

func hit(damage):
	anim_tree.set("parameters/conditions/chasing", true)
	set_process(true)
	health_bar_3d.show()
	health_bar_3d.take_damage(damage)
	audio_stream_player_hit.play()
	health -= damage
	if health <= 0:
		die()
	

func die():
	health_bar_3d.hide()
	%CollisionShape3D.disabled = true
	%AudioStreamGroan.stop()
	audio_stream_player_hit.pitch_scale = 0.7
	audio_stream_player_hit.play()
	anim_tree.set("parameters/conditions/die", true)
	set_process(false)
	
func vanish():
	set_process(false)
	drop.trigger_drop(drop_quantity, drop_item)
	var tween = get_tree().create_tween()
	tween.tween_property(%Skeleton_Warrior, "position", Vector3(0, 0.5, 0), 2)
	tween.tween_property(%Skeleton_Warrior, "position", Vector3(0, -5, 0), 4)
	await get_tree().create_timer(4).timeout
	queue_free()
	


func _on_vision_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		anim_tree.set("parameters/conditions/chasing", true)
		set_process(true)


func _on_vision_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		anim_tree.set("parameters/conditions/resting", true)
		set_process(false)
