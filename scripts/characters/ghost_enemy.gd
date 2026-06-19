extends CharacterBody3D

@export var speed := 4.0
@export var damage_per_hit: int  = 34 
@export var health : int = 100
var player = null
@export var player_path : NodePath
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var eyes: Area3D = $Eyes
@onready var attack_range: Area3D = $attack_range
@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	player = get_node(player_path)
	set_process(false)
	
func _process(_delta: float) -> void:
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * speed
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()


func _on_eyes_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		set_process(true)
		animation_player.play("walk")

func _on_eyes_body_exited(_body: Node3D) -> void:
	pass # Replace with function body.

func hit():
	set_process(true)
	progress_bar.show()
	if health > damage_per_hit:
		health -= damage_per_hit
		progress_bar.value = health
	else:
		progress_bar.hide()
		die()

func die():
	audio_stream_player.play()
	set_process(false)
	disble_areas()
	animation_player.play("die")
	

func disble_areas():
	eyes.monitoring = false
	attack_range.monitoring = false

func vanish():
	set_process(false)
	animation_player.play("vanish")

func _on_attack_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.damage_received()


func _on_attack_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		animation_player.play("walk")
