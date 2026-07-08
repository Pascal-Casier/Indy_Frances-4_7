extends Node3D
class_name Portail

@export var question: String = "Quelle est la capitale ?"
@export var option_gauche: String = "Paris"
@export var option_milieu: String = "Londres"
@export var option_droite: String = "Berlin"
@export_enum("Gauche", "Milieu", "Droite") var correct_answer: int = 0
@export var son : AudioStream
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var trigger_area: Area3D = $trigger_area
@onready var porte_g: Area3D = $porteG
@onready var porte_m: Area3D = $porteM
@onready var porte_d: Area3D = $porteD
@onready var mot1: Label3D = $arche_triple/Cube_D/Label3DG
@onready var mot2: Label3D = $arche_triple/Cube_M/Label3DM
@onready var mot3: Label3D = $arche_triple/Cube_G/Label3DD
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const CORRECT_SOUND = preload("uid://born1mix6seh0")
const INCORRECT_2 = preload("uid://c5k6jemod63hg")

signal repondu(correct: bool)

var _active := true  # évite de se faire retrigger pendant qu'on traverse

func _ready() -> void:
	canvas_layer.visible = false
	trigger_area.body_entered.connect(_on_declenchement)
	porte_g.body_entered.connect(_on_porte.bind(0))
	porte_m.body_entered.connect(_on_porte.bind(1))
	porte_d.body_entered.connect(_on_porte.bind(2))
	if son:
		audio_stream_player.stream = son

func _on_declenchement(body: Node3D) -> void:
	if not _active: return
	%questionlbl.text = question
	mot1.text = option_gauche
	mot2.text = option_milieu
	mot3.text = option_droite
	%mot1.text = option_gauche
	%mot2.text = option_milieu
	%mot3.text = option_droite
	canvas_layer.visible = true
	audio_stream_player.play()

func _on_porte(body: Node3D, index: int) -> void:
	if not _active: return
	_active = false
	canvas_layer.visible = false
	var ok := index == correct_answer
	audio_stream_player.stream = CORRECT_SOUND if ok else INCORRECT_2
	audio_stream_player.play()
	if !ok and body.get_parent() is Jeep2:
		body.get_parent().hit()
	if ok and body.get_parent() is Jeep2:
		body.get_parent().heal()
	repondu.emit(ok)


func _on_trigger_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
