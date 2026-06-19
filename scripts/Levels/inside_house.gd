extends Node2D

@onready var message: Label = %message
@onready var panel_message: Panel = %Panel_message
@onready var notebook: Control = %Notebook
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var note_found : bool = false

func _ready() -> void:
	notebook.mouse_visible = true

func hide_message() -> void:
	await get_tree().create_timer(5).timeout
	panel_message.hide()
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		%Notebook.show()

func _on_lit_mouse_entered() -> void:
	%Line2DLit.show()

func _on_lit_mouse_exited() -> void:
	%Line2DLit.hide()

func _on_livre_mouse_entered() -> void:
	%Line2DLivre.show()

func _on_livre_mouse_exited() -> void:
	%Line2DLivre.hide()


func _on_lit_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		panel_message.show()
		if not note_found:
			note_found = true
			message.text = "Você encontrou uma nota !\n clique na sua agenda para ler."
			Global.add_note("note_title", "Salut fiston !")
			animation_player.play("note_found")
			audio_stream_player.play()
		else:
			message.text = "Não há mais nada !"
		hide_message()

func _on_chaise_mouse_entered() -> void:
	%Line2DChaise.show()

func _on_chaise_mouse_exited() -> void:
	%Line2DChaise.hide()

func _on_livre_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		panel_message.show()
		message.text = "Nada aqui."
		hide_message()

func _on_agenda_pressed() -> void:
	%Notebook.show()

func _on_button_exit_pressed() -> void:
	print("exiting")
	Loader.chang_level("res://scenes/levels/intro_03.tscn")


func _on_bougie_mouse_entered() -> void:
	%Line2DBougie.show()


func _on_bougie_mouse_exited() -> void:
	%Line2DBougie.hide()


func _on_fenetre_mouse_entered() -> void:
	%Line2DFenetre.show()
	

func _on_fenetre_mouse_exited() -> void:
	%Line2DFenetre.hide()


func _on_armoire_mouse_entered() -> void:
	%Line2DArmoire.show()


func _on_armoire_mouse_exited() -> void:
	%Line2DArmoire.hide()
