extends Node3D

@export var scene : PackedScene
@export var spawn_index : int
@export var next_scene_to_spawn : String
@export var next_level_nbr : int = -1
@export_enum("up", "down", "no_anim") var animation_name : String = "no_anim"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawn_position: Node3D = $spawn_position

func _ready() -> void:
	Global.spawn.connect(spawning)
	Global.open_door_gate.connect(spawning)
	
func spawning(index):
	Global.niveau_number = next_level_nbr
	if int(index) == int(spawn_index):
		var new_scene = scene.instantiate()
		new_scene.next_scene = next_scene_to_spawn
		new_scene.position = spawn_position.position
		spawn_position.add_child(new_scene)
		animation_player.play(animation_name)
		$AudioStreamPlayer.play()
