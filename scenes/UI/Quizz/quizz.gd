extends Control

signal success
signal kill_parent
signal exited

@onready var panel = $MarginContainer/Panel
@onready var score_panel = $MarginContainer/ScorePanel

@onready var question = $MarginContainer/Panel/VBoxContainer/HBoxContainer/LblQuestion
@onready var btn_audio = $MarginContainer/Panel/VBoxContainer/HBoxContainer/btnAudio
@onready var choiceA = $MarginContainer/Panel/VBoxContainer/GridContainer/Button1
@onready var choiceB = $MarginContainer/Panel/VBoxContainer/GridContainer/Button2
@onready var choiceC = $MarginContainer/Panel/VBoxContainer/GridContainer/Button3
@onready var choiceD = $MarginContainer/Panel/VBoxContainer/GridContainer/Button4
@onready var lbl_score_2 = $MarginContainer/ScorePanel/VBoxContainer/lblScore2
@onready var lbl_bravo = $MarginContainer/ScorePanel/VBoxContainer/Control/lblBravo
@onready var btn_recommencer = $MarginContainer/ScorePanel/VBoxContainer/btnRecommencer
@onready var grid_container = $MarginContainer/Panel/VBoxContainer/GridContainer
@onready var explications: TextureRect = $MarginContainer/Panel/ColorRect
@onready var timer: Timer = %Timer
@onready var lbl_time: Label = %lblTime

@onready var audio = $AudioStreamPlayer

@export var quizz : Array[Questions]
@export var door_number : int = 0

var last_question 
var running_question := 0
var count := 0
var score := 0
var time_left := 0
var score_total :=0

func _ready():
	z_index = 2
	last_question = quizz.size()-1
	randomize()
	quizz.shuffle()
	running_question = 0
	count = 0
	score = 0
	render_question()
	explications.hide()
	#visibility_changed.connect(_on_visibility_changed)

func start_new_quizz():
	explications.hide()
	randomize()
	quizz.shuffle()
	running_question = 0
	count = 0
	score = 0
	last_question = quizz.size()-1
	render_question()

func render_question():
	explications.hide()
	time_left = 10
	lbl_time.text = str(time_left)
	timer.start()
	var q = quizz[running_question]
	question.text = q.question
	choiceA.text = q.choiceA
	choiceB.text = q.choiceB
	choiceC.text = q.choiceC
	choiceD.text = q.choiceD
	var btn_list = grid_container.get_children()
	btn_list.shuffle()
	for nb in grid_container.get_children():
		grid_container.remove_child(nb)
	for but in btn_list:
		grid_container.add_child(but)
	if q.audiostream != null:
		btn_audio.visible = true
		audio.stream = q.audiostream
	else : 
		btn_audio.visible = false
	$MarginContainer/Panel/ColorRect/Explications.text = q.explications
	
func check_answer(answer: String, _btn_name:String):
	timer.stop()
	for b in grid_container.get_children():
		b.disabled = true
	if answer == quizz[running_question].correct :
		$CorrectSound.play()
		show_correct_answer()
		await get_tree().create_timer(2).timeout
		for b in grid_container.get_children():
			b.disabled = false
		score += 1
		score_total = score * time_left * 10
		#lbl_score_2.text = "score : " + str(score)
		if running_question < last_question:
			running_question +=1
			render_question()
		elif running_question == last_question : 
			end_test()
			
	elif running_question < last_question:
		$IncorrectSound.play()
		show_correct_answer()
		# Réactiver les boutons et continuer
		await get_tree().create_timer(2).timeout
		for b in grid_container.get_children():
			b.disabled = false
		
		if running_question < last_question:
			running_question += 1
			render_question()
		else:
			end_test()
		#await get_tree().create_timer(2).timeout
		#for b in grid_container.get_children():
			#b.disabled = false
		#running_question +=1
		
		
		#render_question()
	else : 
		$IncorrectSound.play()
		show_correct_answer()
		show_explications()
		#await get_tree().create_timer(2).timeout
		for b in grid_container.get_children():
			b.disabled = false
		#end_test()
	
func show_correct_answer():
	match quizz[running_question].correct:
		"a": choiceA.modulate = Color("4de30a")
		"b": choiceB.modulate = Color("4de30a")
		"c": choiceC.modulate = Color("4de30a")
		"d": choiceD.modulate = Color("4de30a")
	await get_tree().create_timer(2).timeout 
	choiceA.modulate = Color("ffffff")
	choiceB.modulate = Color("ffffff")
	choiceC.modulate = Color("ffffff")
	choiceD.modulate = Color("ffffff")
	
func _on_Button1_pressed():
	check_answer("a", choiceA.text)
	
func _on_Button2_pressed():
	check_answer("b", choiceB.text)

func _on_Button3_pressed():
	check_answer("c", choiceC.text)

func _on_Button4_pressed():
	check_answer("d", choiceD.text)

func end_test():
	explications.hide()
	panel.visible = false
	score_panel.visible = true
	lbl_score_2.text = "score : " + str(score_total)
	%lblScore3.text = str(score) + " réponses / " + str(quizz.size())
	if score <= quizz.size() * 0.7:
		lbl_bravo.text = "Insuffisant !"
		btn_recommencer.text = "recommencer"
	else : 
		lbl_bravo.text = "Félicitations !"
		btn_recommencer.text = "Retour au jeu"
		


func _on_btn_recommencer_pressed():
	if btn_recommencer.text == "recommencer":
		score_panel.visible = false
		panel.visible = true
		running_question = 0
		score = 0
		start_new_quizz()
		
	else:
		get_tree().paused = false
		#Global.emit_open_door_gate(door_number)
		kill_parent.emit() # make parent disapear
		score_panel.visible = false
		panel.visible = true
		running_question = 0
		score = 0
		start_new_quizz()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		hide()
		#Global.emit_open_door_gate(door_number)
		#Global.spawn.emit(door_number)
		z_index = -1
		success.emit(door_number)

func begin_quizz():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_btn_exit_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	exited.emit()
	hide()


func _on_btn_audio_pressed():
	audio.play()

func show_explications():
	_on_button_ok_pressed()
	#var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	#tween.tween_property(explications, "position", Vector2(23, 357), 0.9)
	#explications.show()

func _on_button_ok_pressed() -> void:
	
	#var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	#tween.tween_property(explications, "position", Vector2(1050, 1000), 0.3)
	explications.hide()
	for b in grid_container.get_children():
		b.disabled = false
	if running_question == last_question:
		end_test()
	else:
		running_question +=1
		render_question()


#func _on_visibility_changed() -> void:
	#if not is_inside_tree():
		#return
	#
	## Vérifier que get_tree() existe aussi
	#if not get_tree():
		#return
		#
	#if visible:
		#get_tree().paused = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#else:
		#get_tree().paused = false
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_btn_ok_pressed() -> void:
	explications.hide()
	render_question()


func _on_timer_timeout() -> void:
	time_left -= 1
	lbl_time.text = str(time_left)
	if time_left == 0:
		timer.stop()
		show_explications()
		show_correct_answer()
