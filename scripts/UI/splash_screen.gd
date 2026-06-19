extends Control

@onready var progress_bar = $ProgressBar
@onready var loading_label = $LoadingLabel

var scene_to_load: String

func _ready():
	# Démarrer le chargement de la scène principale
	scene_to_load = "res://scenes/UI/main_menu.tscn"  # Remplacez par votre scène
	ResourceLoader.load_threaded_request(scene_to_load)

func _process(_delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(scene_to_load, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# Mise à jour de la barre de progression
			progress_bar.value = progress[0] * 100
			loading_label.text = "Chargement... " + str(int(progress[0] * 100)) + "%"
			
		ResourceLoader.THREAD_LOAD_LOADED:
			# Chargement terminé
			var loaded_scene = ResourceLoader.load_threaded_get(scene_to_load)
			get_tree().change_scene_to_packed(loaded_scene)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			# Erreur de chargement
			loading_label.text = "Erreur de chargement"
			push_error("Échec du chargement de la scène")
