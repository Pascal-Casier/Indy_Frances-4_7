extends Node3D

@export var coin_scene: PackedScene
@export var coins_to_spawn = 5
@export var coin_spread_radius = 0.5

signal drop_completed

func trigger_drop(drop_quantity : int, item : PackedScene):
	var drop_position = global_position
	
	for i in range(drop_quantity):
		spawn_coin(drop_position, item)
	
	emit_signal("drop_completed")

func spawn_coin(drop_position, item):
	var coin = item.instantiate()
	get_tree().current_scene.add_child(coin)
	
	# Calculez une position aléatoire dans un cercle
	var angle = randf() * 2 * PI
	var radius = randf() * coin_spread_radius
	var offset = Vector3(radius * cos(angle), 0.5, radius * sin(angle))
	
	coin.global_position = drop_position + offset
