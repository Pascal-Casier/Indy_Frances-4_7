extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var tile_spawner = $TileSpawner
@onready var ui = $GameUi
@onready var camera = $Camera3D

var score: int = 0
var game_over: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	if game_over:
		return
	# La caméra suit le joueur en Z
	camera.position.z = player.position.z + 5.0
	camera.position.y = 4.0
	camera.rotation.x = deg_to_rad(-15)

func _input(event: InputEvent) -> void:
	print("action jump pressed: ", event.is_action_pressed("jump"))
	if game_over:
		return
	if event.is_action_pressed("left"):
		player.move_left()
	elif event.is_action_pressed("right"):
		player.move_right()
	elif event.is_action_pressed("jump"):
		player.jump()

func add_point() -> void:
	score += 1
	ui.update_score(score)

func trigger_game_over() -> void:
	game_over = true
	ui.show_game_over(score)
