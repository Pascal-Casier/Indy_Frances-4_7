extends Node

var current_checkpoint: Checkpoint
var default_checkpoint_position: Vector3
var checkpoints_data: Dictionary = {}

func set_default_checkpoint(position: Vector3):
	default_checkpoint_position = position
	# Réinitialiser le checkpoint actuel quand on change de niveau
	current_checkpoint = null
	print("Checkpoint par défaut défini à: ", position)

func set_active_checkpoint(checkpoint: Checkpoint):
	current_checkpoint = checkpoint
	save_checkpoint_data(checkpoint)
	print("Checkpoint actuel: ", checkpoint.checkpoint_id)

func respawn_player():
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("Aucun joueur trouvé!")
		return
	
	var respawn_position: Vector3
	
	if current_checkpoint:
		# Respawn au checkpoint actuel
		respawn_position = current_checkpoint.get_respawn_position()
		print("Respawn au checkpoint: ", current_checkpoint.checkpoint_id)
	else:
		# Respawn au checkpoint par défaut (position initiale du joueur)
		respawn_position = default_checkpoint_position
		print("Respawn au checkpoint par défaut")
	
	# Appliquer la position de respawn
	player.global_position = respawn_position
	player.velocity = Vector3.ZERO
	
	if player.has_method("reset_player_state"):
		player.reset_player_state()

func save_checkpoint_data(checkpoint: Checkpoint):
	checkpoints_data[get_tree().current_scene.scene_file_path] = {
		"checkpoint_id": checkpoint.checkpoint_id,
		"position": checkpoint.global_position,
		"timestamp": Time.get_unix_time_from_system()
	}

func clear_checkpoints():
	current_checkpoint = null
	checkpoints_data.clear()
