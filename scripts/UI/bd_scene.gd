extends Control


# Référencez vos images/pages dans l'éditeur
@export var pages: Array[Texture2D] = []
@export var page_sounds: Array[AudioStream] = []  # Sons pour chaque page
@export var page_display_time: float = 3.0  # Durée d'affichage de chaque page
@export var fade_duration: float = 0.5       # Durée du dégradé blanc

@onready var page_texture: TextureRect = $PageTexture
@onready var white_overlay: ColorRect = $WhiteOverlay
@onready var audio_player: AudioStreamPlayer = $AudioPlayer

var current_page_index: int = 0

func _ready():
	# Configuration de l'overlay blanc
	white_overlay.color = Color.WHITE
	white_overlay.modulate.a = 1.0  # Commence opaque (blanc)
	
	# Assurer que l'overlay couvre tout l'écran
	white_overlay.size = get_viewport_rect().size
	white_overlay.position = Vector2.ZERO
	
	# Configuration du TextureRect (optionnel - ajustez selon vos besoins)
	page_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE  # ou EXPAND_FIT_WIDTH, etc.
	page_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if pages.size() > 0:
		page_texture.texture = pages[0]
		start_intro()
	else:
		push_error("Aucune page n'a été ajoutée !")

func start_intro():
	# Apparition de la première page via dégradé blanc
	fade_from_white()

func fade_from_white():
	# Le blanc disparaît pour révéler l'image
	var tween = create_tween()
	tween.tween_property(white_overlay, "modulate:a", 0.0, fade_duration)
	
	# Jouer le son associé à cette page
	play_page_sound(current_page_index)
	
	await tween.finished
	
	# Attendre avant de passer à la page suivante
	await get_tree().create_timer(page_display_time).timeout
	next_page()

func next_page():
	current_page_index += 1
	
	if current_page_index < pages.size():
		# Transition vers la page suivante
		transition_to_page(current_page_index)
	else:
		# Fin de l'intro - transition finale en blanc
		end_intro()

func transition_to_page(page_index: int):
	var tween = create_tween()
	
	# Dégradé vers le blanc
	tween.tween_property(white_overlay, "modulate:a", 1.0, fade_duration)
	
	await tween.finished
	
	# Changer la texture pendant que c'est blanc
	page_texture.texture = pages[page_index]
	
	# Dégradé depuis le blanc (révèle la nouvelle page)
	fade_from_white()

func end_intro():
	# Transition finale en blanc puis chargement de la scène suivante
	var tween = create_tween()
	tween.tween_property(white_overlay, "modulate:a", 1.0, fade_duration)
	
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	
	# Charger la scène principale (adaptez le chemin)
	Loader.chang_level("res://scenes/levels/maison_vovo.tscn")

func _input(event):
	# Clic souris ou Espace : passe à l'image suivante
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
	   or event.is_action_pressed("ui_accept"):
		next_page()
	
	# Échap : sauter directement au menu
	elif event.is_action_pressed("ui_cancel"):
		skip_intro()

func skip_intro():
	# Arrêter toutes les animations en cours
	for child in get_children():
		if child is TextureRect or child is ColorRect:
			var tween = child.get_tree()
			if tween:
				# Tuer les tweens actifs
				get_tree().call_group("tween", "kill")
	
	# Arrêter le son
	audio_player.stop()
	
	end_intro()

func play_page_sound(page_index: int):
	# Jouer le son si disponible pour cette page
	if page_index < page_sounds.size() and page_sounds[page_index] != null:
		audio_player.stream = page_sounds[page_index]
		audio_player.play()
