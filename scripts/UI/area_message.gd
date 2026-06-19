extends Area3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@export var door_nbr := -1
@export var new_text : String = "Pour ouvrir la porte,paie 6 euros"
@export var coins_nbr := 0
var player = null
const CORRECT_ANSWER = preload("res://assets/sounds/sfx/correct_answer.mp3")
const INCORRECT_2 = preload("res://assets/sounds/sfx/incorrect2.ogg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Label.text = new_text

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		body.can_move = false
		canvas_layer.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = null


func _on_button_1_pressed() -> void:
	if player:
		player.can_move = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		player = null
		canvas_layer.hide()
		if Global.coins >= coins_nbr:
			Global.emit_open_door_gate(door_nbr)
			Global.coins -= coins_nbr
			Global.emit_coins_updated()
			queue_free()


func _on_button_2_pressed() -> void:
	if player:
		player.can_move = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		player = null
		canvas_layer.hide()
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
