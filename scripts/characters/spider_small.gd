extends CharacterBody3D

@export var navigation := false
@export var speed := 4.0
@export var damage_per_hit: int  = 34 
@export var health : int = 100
var player = null
@export var player_path : NodePath
var vertical_velocity := 0.0
var is_dead := false
var is_active := false

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
var stomped : bool = false


func _ready() -> void:
	if player_path:
		player = get_node(player_path)
	set_process(false)
	
	
func _process(delta: float) -> void:
	if not player or not is_active:
		return
	var direction = Vector3.ZERO
	if navigation:
		nav_agent.set_target_position(player.global_transform.origin)
		var next_nav_point = nav_agent.get_next_path_position()
		direction = (next_nav_point - global_transform.origin).normalized()
	else:
		direction = (player.position - global_transform.origin).normalized()

	# Horizontal movement
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Appliquer la gravité
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	else:
		vertical_velocity = 0.0  # Remise à 0 quand on touche le sol

	# Appliquer la vitesse verticale
	velocity.y = vertical_velocity

	# Regarder vers le joueur (en 2D horizontal)
	var distance = global_position.distance_to(player.global_position)
	if distance > 0.2:
		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

	move_and_slide()

func _on_eyes_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_active = true
		set_process(true)
		animation_player.play("Spider_Walk")
		%AudioStreamPlayerScream.play()

func _on_eyes_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

func hit(_value):
	if is_dead:
		return
	progress_bar.show()
	is_active = false
	set_process(false)
	health -= damage_per_hit
	progress_bar.value = health
	
	if health > 0:
		speed += 0.5
		audio_stream_player.stream = HURTSOUND
		audio_stream_player.pitch_scale = 3.0
		audio_stream_player.play()
		animation_player.play("knockback")
		await animation_player.animation_finished
		is_active = true
		set_process(true)
		animation_player.play("Spider_Walk")
	else:
		is_dead = true
		progress_bar.hide()
		die()
		#set_process(false)

func die():
	disble_areas()
	$SpiderArmature/contour.hide()
	audio_stream_player.stream = MUTANTDIE
	audio_stream_player.pitch_scale = 1.0
	audio_stream_player.play()
	%AudioStreamPlayerScream.stop()
	var camera = get_tree().get_first_node_in_group("camera")  # Ajoute ta caméra au groupe "camera"
	if camera:
		camera.add_shake(0.3)  # 0.3 pour un shake léger, augmente pour plus d'intensité
	flash.emitting = true
	smoke.emitting = true
	set_process(false)
	# Désactive les collisions physiques
	collision_layer = 0
	collision_mask = 0
	if !stomped:
		animation_player.play("Spider_Death")
	else:
		animation_player.play("smashed")

func disble_areas():
	eyes.set_deferred("monitoring",false)
	eyes.set_deferred("monitorable",false)
	attack_range.set_deferred("monitoring", false)
	attack_range.set_deferred("monitorable", false)
	%StompArea.set_deferred("monitoring", false)
	%StompArea.set_deferred("monitorable", false)

func vanish():
	set_process(false)
	animation_player.play("vanish")

func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_dead:
		animation_player.play("Spider_Attack")
		

func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_dead:
		animation_player.play("Spider_Walk")


func _on_stomp_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not is_dead:
		is_dead = true
		stomped = true
		disble_areas()
		body.jumping = true
		body.vertical_velocity = 12
		die()
		progress_bar.hide()

func bite() -> void:
	if player and player.has_method("damage_received"):
		player.damage_received()
	
