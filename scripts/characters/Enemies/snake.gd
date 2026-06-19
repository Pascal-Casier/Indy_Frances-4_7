extends CharacterBody3D

@export var navigation := false
@export var speed := 4.0
@export var damage_per_hit: int  = 34 
@export var health : int = 100
@export var attack_distance := 1.5  # Ajuste selon ta zone d'attaque
var player = null
var vertical_velocity := 0.0
var is_attacking := false
var player_in_range := false

var original_velocity: Vector3
var knockback_tween: Tween
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var eyes: Area3D = $Eyes
@onready var attack_range: Area3D = $attack_range
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var stomp_area: Area3D = %StompArea
var gravity := 9
const HURTSOUND = preload("res://assets/sounds/sfx/ow_hurtsound.mp3")
const MUTANTDIE = preload("res://assets/sounds/sfx/cartoon-fart-or-splat.mp3")
@onready var flash: GPUParticles3D = $Node3D/flash
@onready var smoke: GPUParticles3D = $Node3D/smoke


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	set_process(false)
	
	
func _process(delta: float) -> void:
	var distance = global_position.distance_to(player.global_position)
	
	# Gestion attaque par distance au lieu des signaux Area3D
	if distance <= attack_distance:
		if not is_attacking:
			start_attack()
	else:
		if is_attacking:
			stop_attack()
	
	if is_attacking:
		return  # Ne pas bouger pendant l'attaque
	
	# --- Mouvement normal ---
	var direction = Vector3.ZERO
	if navigation:
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		direction = (next_nav_point - global_transform.origin).normalized()
	else:
		direction = (player.position - global_transform.origin).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0
	velocity.y = vertical_velocity

	if distance > 0.2:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()

func _on_eyes_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_process(true)
		animation_player.play("Snake_Walk")

func _on_eyes_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

func hit(_value):
	progress_bar.show()
	set_process(false)
	if health > damage_per_hit:
		speed += 0.5
		audio_stream_player.stream = HURTSOUND
		audio_stream_player.pitch_scale = 3.0
		audio_stream_player.play()
		animation_player.play("knockback")
		health -= damage_per_hit
		progress_bar.value = health
		await animation_player.animation_finished
		set_process(true)
		animation_player.play("Snake_Walk")
	else:
		progress_bar.hide()
		die()
		set_process(false)

func die():
	audio_stream_player.stream = MUTANTDIE
	audio_stream_player.pitch_scale = 1.0
	audio_stream_player.play()
	flash.emitting = true
	smoke.emitting = true
	set_process(false)
	disble_areas()
	animation_player.play("Snake_Death")

func disble_areas():
	eyes.monitoring = false
	attack_range.monitoring = false

func vanish():
	set_process(false)
	animation_player.play("vanish")

func _on_attack_range_body_entered(body: Node3D) -> void:
	print("body entered attack range: ", body.name)
	if body.is_in_group("Player"):
		print("PLAYER in range - is_attacking: ", is_attacking)
		is_attacking = true
		set_process(false)
		animation_player.play("Snake_Attack")

func _on_attack_range_body_exited(body: Node3D) -> void:
	print("body exited attack range: ", body.name)
	if body.is_in_group("Player"):
		print("PLAYER left range")
		is_attacking = false
		set_process(true)
		animation_player.play("Snake_Walk")

func start_attack():
	is_attacking = true
	velocity = Vector3.ZERO  # Stoppe net le mouvement
	animation_player.play("Snake_Attack")

func stop_attack():
	is_attacking = false
	animation_player.play("Snake_Walk")



func _on_stomp_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		stomp_area.set_deferred("monitoring", false)
		body.jumping = true
		body.vertical_velocity = 12
		die()
		progress_bar.hide()

func bite() -> void:
	print("bite() called - is_attacking: ", is_attacking)
	if player:
		player.damage_received()
		$Snake2/AudioStreamPlayerBite.play()
	if is_attacking:
		animation_player.play("Snake_Attack")
	
