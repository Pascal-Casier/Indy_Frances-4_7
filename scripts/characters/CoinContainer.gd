extends Node3D

func _ready():
	# Attendre un court instant avant de libérer les pièces
	await get_tree().create_timer(0.1).timeout
	var parent = get_parent()
	for coin in get_children():
		var global_coin_position = coin.global_position
		remove_child(coin)
		parent.add_child(coin)
		coin.global_position = global_coin_position
	queue_free()
