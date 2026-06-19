class_name DictionnaryPanel extends Control

@export var title : String = "Dictionnaire"
@export var resource_list : Array[ResourceWord]
@export var quizz : bool = false
@export var door_nb : int = -1
@onready var quizzPanel: Control = $Control

@onready var button_quizz: Button = $TextureRect/ButtonQuizz

@onready var grid_container: GridContainer = %GridContainer
var buttons_list = []

func _ready() -> void:
	if quizz:
		button_quizz.show()
		var tween = create_tween()
		tween.set_loops() # Boucle infinie
	
	# Animation de pulsation
		tween.tween_property(button_quizz, "scale", Vector2(1.1, 1.1), 0.5)
		tween.tween_property(button_quizz, "scale", Vector2(1.0, 1.0), 0.5)
	else:
		button_quizz.hide()
	%Label.text = title
	for i in resource_list.size():
		var b = Button.new()
		
		b.text = resource_list[i].word
		
		# Créer un AudioStreamPlayer pour chaque bouton
		var audio_player = AudioStreamPlayer.new()
		b.add_child(audio_player)
		
		# Assigner le son immédiatement si disponible
		if i < resource_list.size():
			audio_player.stream = resource_list[i].sound
		
		# Connecter le signal "pressed" du bouton à une fonction qui jouera le son
		b.connect("pressed", Callable(self, "_on_button_pressed").bind(audio_player))
		
		# Assigner l'icône si disponible
		if i < resource_list.size():
			b.icon = resource_list[i].photo
			b.expand_icon = true
		
		grid_container.add_child(b)
		buttons_list.append(b)
	
	for but in grid_container.get_children():
		but.custom_minimum_size = Vector2(170, 66)

# Fonction appelée lorsqu'un bouton est pressé
func _on_button_pressed(audio_player: AudioStreamPlayer) -> void:
	if audio_player.stream:
		audio_player.play()


func _on_button_exit_pressed() -> void:
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_quizz_pressed() -> void:
	quizzPanel.resource_list = resource_list
	quizzPanel.door_nbr = door_nb
	quizzPanel.show()
	quizzPanel.setup_quiz()
	

func _on_control_exit() -> void:
	hide()
