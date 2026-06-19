extends Node3D


@export_multiline var title : String = "[E]"
@onready var press_e_lbl: Label3D = %PressELbl
@onready var control: Control = %Control
@export var payant : bool = false
@export var price : int = 5
@export var message_label : Label
@export var message : Control
@export var audio_player : AudioStreamPlayer
@export var led : Node3D


var player
var already_paid := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	press_e_lbl.text = title
	if message_label:
		message_label.text = "PAYER " + str(price) + " PIÈCES ?"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_lbl.visible:
		press_e_lbl.hide()
		if payant and not already_paid:
			if message:
				message.show()
				already_paid = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				if player:
					player.can_move = false
		else:
			show_quizz()
		pass

func show_quizz() -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	control.show()
	if control.get_child_count() > 0:
		control.get_child(0).show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if player:
			player.can_move = false

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _body.is_in_group("Player"):
		if player:
			press_e_lbl.show()
			if led :
				led.show()


func _on_area_3d_body_exited(_body: Node3D) -> void:
	if _body.is_in_group("Player"):
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if player:
			press_e_lbl.hide()
			if led :
				led.hide()


func _on_button_ok_pressed() -> void:
	
	if Global.coins >= price:
		Global.coins -= price
		Global.emit_coins_updated()
		if message:
			message.hide()
		if audio_player:
			audio_player.play()
		await get_tree().create_timer(1).timeout
		show_quizz()


func _on_button_cancel_pressed() -> void:
	message.hide()
	already_paid = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player:
		player.can_move = true
	
