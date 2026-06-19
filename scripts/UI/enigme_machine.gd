extends Control


signal success
@onready var word_1: Label = %word1
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var btn_1: Button = $ColorRect/TextureRect/VBoxContainer/HBoxContainer2/btn1 as Button

const CORRECT_2 = preload("res://assets/sounds/sfx/correct2.ogg")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect2.ogg")

@export var wordslist : Array[String]
@export var response : String
@export var chances : int = 3
var score := 0

func _ready() -> void:
	update_score()
	randomize()
	wordslist.shuffle()
	for w in wordslist:
		word_1.text += w + " "

func change_list_order():
	var longueur = wordslist.size()
	# Parcourez le tableau en commençant par la fin
	for i in range(longueur - 1, 0, -1):
		# Générez un index aléatoire entre 0 et i (inclus)
		var indexAleatoire = randi() % (i + 1)
		
		# Permutez les éléments à l'index actuel et à l'index aléatoire
		var temp = wordslist[i]
		wordslist[i] = wordslist[indexAleatoire]
		wordslist[indexAleatoire] = temp
	wordslist.shuffle()
	word_1.text = ""
	for w in wordslist:
		word_1.text += w + " "


func verify_response():
	if score < chances -1 :
		score +=1
		update_score()
	else:
		%lblScore.text = str(chances) + "/" + str(chances)
		word_1.text = "Perdu !!!"
		btn_1.hide()
		%BtnTest.text = "recommencer"
		
	if word_1.text == response + " ":
		audio_stream_player.stream = CORRECT_2
		audio_stream_player.play()
		word_1.text = "Félicitations !!"
		%BtnTest.text = "sortir"
		btn_1.hide()
	else:
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()

func update_score():
	%lblScore.text = str(score) + "/" + str(chances)
	
func _on_btn_1_pressed() -> void:
	change_list_order()

func _on_btn_test_pressed() -> void:
	if %BtnTest.text == "recommencer":
		get_tree().reload_current_scene()
	elif %BtnTest.text == "sortir":
		emit_signal("success")
		hide()
	else:
		verify_response()

func _on_btn_exit_pressed() -> void:
	hide()
