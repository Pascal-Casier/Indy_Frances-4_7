extends Control

@export var duree_affichage : float = 2.5      # temps de "chargement"
@export var temps_fade : float = 1.0           
@export var logo_texture : Texture2D
@export var scene_suivante : PackedScene

@onready var logo : TextureRect = $TextureRect
@onready var fond_noir : ColorRect = $ColorRect
@onready var loading_dots : HBoxContainer = $LoadingDots  # HBox avec 3 Labels "."

var dot_tweens : Array[Tween] = []  # pour arrêter l'anim plus tard

func _ready() -> void:
	# Fond plein écran
	#fond_noir.color = Color.BLACK
	#fond_noir.anchor_left = 0
	#fond_noir.anchor_top = 0
	#fond_noir.anchor_right = 1
	#fond_noir.anchor_bottom = 1
	
	# Logo centré
	#logo.texture = logo_texture
	#logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#logo.anchor_left = 0.5
	#logo.anchor_top = 0.5
	#logo.anchor_right = 0.5
	#logo.anchor_bottom = 0.5
	#logo.offset_left = -300
	#logo.offset_top = -300
	#logo.offset_right = 300
	#logo.offset_bottom = 300
	
	# Dots de chargement : centrés sous le logo, invisibles au début
	loading_dots.anchor_left = 1.0
	loading_dots.anchor_top = 1.0
	loading_dots.anchor_right = 1.0
	loading_dots.anchor_bottom = 1.0
	loading_dots.offset_top = 100  # sous le logo
	loading_dots.modulate.a = 0    # transparent au début
	
	# Commence transparent
	modulate.a = 0
	
	# Animation principale
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, temps_fade)  # fade in
	tween.tween_callback(start_loading_animation)               # ← démarre les points
	tween.tween_interval(duree_affichage)                       # temps de chargement
	tween.tween_callback(stop_loading_animation)                # ← arrête les points
	tween.tween_property(self, "modulate:a", 0.0, temps_fade)   # fade out
	tween.tween_callback(change_to_next_scene)

func start_loading_animation() -> void:
	# Montre les dots
	var show_tween = create_tween()
	show_tween.tween_property(loading_dots, "modulate:a", 1.0, 0.3)
	
	# Animation infinie : chaque point pulse avec décalage
	var labels = loading_dots.get_children()  # tes 3 Labels
	for i in range(labels.size()):
		var label = labels[i]
		var t = create_tween()
		t.set_loops()  # boucle infinie
		t.tween_interval(i * 0.3)  # décalage
		t.tween_property(label, "scale", Vector2(1.5, 1.5), 0.5)
		t.tween_property(label, "scale", Vector2(1.0, 1.0), 0.5)
		dot_tweens.append(t)
		
	if scene_suivante:
		ResourceLoader.load_threaded_request(scene_suivante.resource_path)

func stop_loading_animation() -> void:
	# Cache les dots
	var hide_tween = create_tween()
	hide_tween.tween_property(loading_dots, "modulate:a", 0.0, 0.3)
	
	# Arrête toutes les anims
	for t in dot_tweens:
		if t:
			t.kill()
	dot_tweens.clear()

func change_to_next_scene() -> void:
	if scene_suivante != null:
		get_tree().change_scene_to_packed(scene_suivante)
	else:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
