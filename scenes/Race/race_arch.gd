extends Node3D

signal correct(bool)

@onready var label_3d_1: Label3D = $arche_triple/Cube_002/Label3D2
@onready var label_3d_2: Label3D = $arche_triple/Cube_001/Label3D
@onready var label_3d_3: Label3D = $arche_triple/Cube_003/Label3D3
@onready var area_3d_1: Area3D = $Area3D2
@onready var area_3d_2: Area3D = $Area3D
@onready var area_3d_3: Area3D = $Area3D3
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var mot_1: Label = %mot1
@onready var mot_2: Label = %mot2
@onready var mot_3: Label = %mot3
@onready var questionlbl: Label = %questionlbl
@onready var audio_question: AudioStreamPlayer = %AudioQuestion

@export var question : String = "ma question"
@export var question_audio : AudioStream
@export var mots : Array[String]
@export_range(0, 2, 1) var correct_word : int

const CORRECT_SOUND = preload("uid://born1mix6seh0")
const INCORRECT_SOUND = preload("res://assets/sounds/sfx/wrong_answer.mp3")

func _ready() -> void:
	label_3d_1.text = mots[0]
	label_3d_2.text = mots[1]
	label_3d_3.text = mots[2]
	area_3d_1.body_entered.connect(_on_body_entered.bind(0))
	area_3d_2.body_entered.connect(_on_body_entered.bind(1))
	area_3d_3.body_entered.connect(_on_body_entered.bind(2))
	mot_1.text = mots[0]
	mot_2.text = mots[1]
	mot_3.text = mots[2]
	questionlbl.text = question
	if audio_question:
		audio_question.stream = question_audio
	
func _on_body_entered(body: Node3D, area_id : int) -> void:
	if body.get_parent() is Jeep2:
		
		if area_id == correct_word:
			correct.emit(true)
			audio_stream_player.stream = CORRECT_SOUND
			audio_stream_player.play()
		
		else :
			correct.emit(false)
			audio_stream_player.stream = INCORRECT_SOUND
			audio_stream_player.play()
			body.get_parent().hit()
			
		shut_down()

func shut_down() -> void:
	area_3d_1.set_deferred("monitoring", false)
	area_3d_2.set_deferred("monitoring", false)
	area_3d_3.set_deferred("monitoring", false)
	label_3d_1.text = "---"
	label_3d_2.text = "---"
	label_3d_3.text = "---"
	canvas_layer.hide()
	$trigger_area.set_deferred("monitoring", false)


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.get_parent() is Jeep2:
		canvas_layer.show()
		if question_audio:
			audio_question.play()
