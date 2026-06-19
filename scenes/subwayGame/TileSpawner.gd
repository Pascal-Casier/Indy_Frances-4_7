extends Node3D


@export var tile_scene: PackedScene = null
@export var speed: float = 8.0          # vitesse d'avance des dalles
@export var spawn_distance: float = 40.0
@export var tile_length: float = 4.0   # longueur d'une dalle en Z
@export var avoir_ratio: float = 0.35  # 35% de chance d'être un verbe AVOIR

# Conjugaisons AVOIR
const AVOIR_VERBS = [
	"j'ai", "tu as", "il a", "elle a",
	"nous avons", "vous avez", "ils ont", "elles ont",
	"j'avais", "tu avais", "il avait",
	"j'aurai", "tu auras", "il aura",
	"j'aurais", "tu aurais", "il aurait",
	"que j'aie", "que tu aies", "qu'il ait"
]

# Conjugaisons d'autres verbes (distracteurs)
const OTHER_VERBS = [
	"je suis", "tu es", "il est", "nous sommes",
	"je vais", "tu vas", "il va",
	"je fais", "tu fais", "il fait",
	"je prends", "tu prends", "il prend",
	"je veux", "tu veux", "il veut",
	"je peux", "tu peux", "il peut",
	"je dois", "tu dois", "il doit",
	"je viens", "tu viens", "il vient",
	"je mange", "tu manges", "il mange",
	"je parle", "tu parles", "il parle"
]

var active_tiles: Array = []
var player_ref: CharacterBody3D
var next_spawn_z: float = -10.0

func _ready() -> void:
	player_ref = get_parent().get_node("Player")
	# Pré-spawner quelques dalles
	for i in range(12):
		_spawn_row()

func _process(delta: float) -> void:
	# Déplacer toutes les dalles vers le joueur (+Z)
	for tile in active_tiles:
		tile.position.z += speed * delta

	# Supprimer les dalles derrière le joueur
	active_tiles = active_tiles.filter(func(t):
		if t.position.z > player_ref.position.z + 10.0:
			t.queue_free()
			return false
		return true
	)

	# Spawner si nécessaire
	if active_tiles.is_empty() or active_tiles.back().position.z > next_spawn_z - spawn_distance:
		_spawn_row()

func _spawn_row() -> void:
	for lane in range(3):
		var is_avoir = randf() < avoir_ratio
		var verb: String
		if is_avoir:
			verb = AVOIR_VERBS[randi() % AVOIR_VERBS.size()]
		else:
			verb = OTHER_VERBS[randi() % OTHER_VERBS.size()]

		var tile: Node3D = tile_scene.instantiate()
		get_parent().add_child.call_deferred(tile)  # ← ici
		tile.position = Vector3(
			[-2.0, 0.0, 2.0][lane],
			0.0,
			next_spawn_z
		)
		tile.setup(verb, is_avoir, get_parent())
		active_tiles.append(tile)

	next_spawn_z -= tile_length
