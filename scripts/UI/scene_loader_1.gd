extends Control

@export var backgrounds : Array[Texture2D]
@onready var loading_bar: ProgressBar = $ProgressBar
@onready var texture_rect: TextureRect = $TextureRect

var scene_path : String
var progress : Array
var update : float = 0.0

func _ready() -> void:
	randomize()
	if backgrounds.size() > 0:
		var random_index = randi() % backgrounds.size()
		var random_texture = backgrounds[random_index]
		texture_rect.texture = random_texture
	scene_path = Loader.scene_path
	ResourceLoader.load_threaded_request(scene_path)
	
func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	if progress[0] > update:
		update = progress[0]
	if loading_bar.value >= 1.0:
		if update >= 1.0:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
			
	if loading_bar.value < update:
		loading_bar.value = lerp(loading_bar.value, update, delta)
	loading_bar.value += delta * 0.2 * (0.5 if update >= 1.0 else clamp(0.9 - loading_bar.value, 0.0, 1.0))
		
