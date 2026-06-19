extends Area3D
class_name InteractableObject

signal right_answer(obect_name)
signal wrong_answer
const CORRECT_ANSWER = preload("res://assets/sounds/sfx/correct_answer.mp3")
const WRONG_ANSWER = preload("res://assets/sounds/sfx/wrong_answer.mp3")
@export var object_name: String = "Chaise"
@export var traducao : String = "Cadeira"
@export var categoria : String = "meubles"
@export var wrong_answers: Array[String] = ["Table", "Lampe"]
@export var object_sound : AudioStream

@onready var press_e: Label3D = $PressE
@onready var control: Control = $Control
@onready var btns_container: HBoxContainer = $Control/HBoxContainer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var player = null
var all_answers := []

func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]
	randomize()
	all_answers = [object_name] + wrong_answers
	all_answers.shuffle()
	var buttons = btns_container.get_children()
	for i in range(min(3, all_answers.size())):
		buttons[i].text = all_answers[i]
		buttons[i].set_meta("answer", all_answers[i])
		buttons[i].set_meta("is_correct", all_answers[i] == object_name)
	for b in btns_container.get_children():
		b.pressed.connect(_on_btn_pressed.bind(b))


func _on_btn_pressed(btn: Button) -> void:
	if btn.text == object_name :
		if object_sound:
			audio_stream_player.stream = object_sound
		else:
			audio_stream_player.stream = CORRECT_ANSWER
		audio_stream_player.play()
		right_answer.emit(object_name)
		Global.emit_signal("note_collected", 
		{object_name: traducao}, 
		categoria
	)
		if player:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			player.can_move = true
		control.hide()
		await audio_stream_player.finished
		queue_free()
	else:
		audio_stream_player.stream = WRONG_ANSWER
		audio_stream_player.play()
		wrong_answer.emit()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible:
		control.show()
		if player:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			player.can_move = false
