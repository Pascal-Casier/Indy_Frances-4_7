extends Control

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var grid_container: GridContainer = %GridContainer
var tweens = {}  # Dictionnaire pour stocker les tweens de chaque bouton


@onready var boutons = {
	"Button1": "res://scenes/levels/1.tscn",
	"Button2": "res://scenes/levels/2.tscn",
	"Button3": "res://scenes/levels/3.tscn",
	"Button4": "res://scenes/levels/3.tscn",
	"Button5": "res://scenes/levels/3.tscn",
	"Button6": "res://scenes/levels/3.tscn",
	"Button7": "res://scenes/levels/3.tscn",
	"Button8": "res://scenes/levels/3.tscn",
	"Button9": "res://scenes/levels/3.tscn",
	"Button10": "res://scenes/levels/3.tscn",
	"Button11": "res://scenes/levels/3.tscn",
	"Button12": "res://scenes/levels/3.tscn",
	"Button13": "res://scenes/levels/3.tscn",
	"Button14": "res://scenes/levels/3.tscn",
	"Button15": "res://scenes/levels/3.tscn"
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	var buts = get_tree().get_nodes_in_group("boutons")
	for b in buts:
		b.mouse_entered.connect(play_sound)
		b.scale = Vector2.ONE  # taille de base
		b.pivot_offset = b.size / 2  # Centre le pivot au milieu du bouton
		b.mouse_entered.connect(_on_mouse_entered.bind(b))
		b.mouse_exited.connect(_on_mouse_exited.bind(b))
	
	rafraichir_boutons()
	# On écoute le signal de Global, même si on change de scène et qu'on revient
	Global.niveau_debloque_change.connect(rafraichir_boutons)


	for nom in boutons.keys():
		var button = grid_container.get_node(nom)
		button.pressed.connect(_on_bouton_pressed.bind(nom))

func play_sound() -> void:
	audio_stream_player.pitch_scale = randf_range(0.9, 1.1) # variation légère
	audio_stream_player.play()

func _on_bouton_pressed(nom) -> void:
	var path = boutons[nom]
	Loader.chang_level(path)

func _on_mouse_entered(b) -> void:
	# Tue le tween spécifique à ce bouton s'il existe
	if tweens.has(b) and tweens[b]:
		tweens[b].kill()
	
	tweens[b] = create_tween()
	tweens[b].set_trans(Tween.TRANS_ELASTIC)
	tweens[b].set_ease(Tween.EASE_OUT)
	tweens[b].tween_property(b, "scale", Vector2(1.15, 1.15), 0.3)

func _on_mouse_exited(b):
	# Tue le tween spécifique à ce bouton s'il existe
	if tweens.has(b) and tweens[b]:
		tweens[b].kill()
	
	tweens[b] = create_tween()
	tweens[b].set_trans(Tween.TRANS_ELASTIC)
	tweens[b].set_ease(Tween.EASE_OUT)
	tweens[b].tween_property(b, "scale", Vector2.ONE, 0.3)
	
func _on_button_exit_pressed() -> void:
	hide()

func rafraichir_boutons() -> void:
	var niveau_max = Global.niveau_number
	var i := 1
	
	for bouton in grid_container.get_children():
		if bouton is Button:
			var num_niveau := i
			
			# Débloqué ou pas ?
			var debloc = num_niveau <= niveau_max
			bouton.disabled = !debloc
			
			# Aspect visuel
			if debloc:
				bouton.text = str(num_niveau)
				bouton.modulate = Color.WHITE
			else:
				bouton.text = "🔒"
				bouton.modulate = Color(0.5, 0.5, 0.5, 1)  # gris foncé
			
			# On connecte le pressed une seule fois
			if not bouton.pressed.is_connected(_on_niveau_pressed):
				bouton.pressed.connect(_on_niveau_pressed.bind(num_niveau))
			
			i += 1

func _on_niveau_pressed(num_niveau: int) -> void:
	if num_niveau <= Global.niveau_number:
		get_tree().change_scene_to_file("res://scenes/levels/%d.tscn" % num_niveau)
	else:
		# Optionnel : petit feedback
		print("Niveau verrouillé")
