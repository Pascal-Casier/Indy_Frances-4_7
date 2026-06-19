extends RigidBody3D


@export var delai_explosion: float = 1.9 # Temps avant BOUM
@export var degats: int = 25
@export var rayon_detection: float = 2.0  # Zone de déclenchement
@export var rayon_explosion: float = 6.0

@onready var explosion: Node3D = $explosion
@onready var zone_degats: Area3D = %zone_degats
@onready var bomb_mesh: MeshInstance3D = $Prop_Bomb
@onready var proxim_zone: Area3D = $proxim_zone

@onready var audio_stream_player_3d: AudioStreamPlayer3D = %AudioStreamPlayer3D
@onready var press_e_label_3d: Label3D = %PressELabel3D

const BOMB_FUSE_EFFECT_LOOP = preload("res://assets/sounds/sfx/BombFuse_effect_loop.mp3")
const EXPLOSION_2 = preload("res://assets/sounds/sfx/explosion2.mp3")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_label_3d.visible:
		amorcer_bomb()
		proxim_zone.set_deferred("monitoring", false)
		press_e_label_3d.hide()
		
func amorcer_bomb() -> void:
	audio_stream_player_3d.stream = BOMB_FUSE_EFFECT_LOOP
	audio_stream_player_3d.play()
	await audio_stream_player_3d.finished
	audio_stream_player_3d.stream = EXPLOSION_2
	audio_stream_player_3d.play()
	explode()

func explode() -> void:
	for c in explosion.get_children():
		if c is GPUParticles3D:
			c.emitting = true
	audio_stream_player_3d.play()
	bomb_mesh.hide()
	var corps_touches = zone_degats.get_overlapping_bodies()
	for corps in corps_touches:
		if corps.has_method("damage_received"):
			# Optionnel : Calculer la distance pour réduire les dégâts si on est loin
			var distance = global_position.distance_to(corps.global_position)
			if distance <= rayon_explosion:
				#corps.recevoir_degats(degats)
				corps.damage_received()
	await get_tree().create_timer(1.5).timeout
	queue_free()

func _on_proxim_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group('Player'):
		press_e_label_3d.show()

func _on_proxim_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group('Player'):
		press_e_label_3d.hide()
