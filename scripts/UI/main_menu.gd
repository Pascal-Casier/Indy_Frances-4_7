extends Control
class_name MainMenu

@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/Options_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var options_menu = $Options_Menu as OptionsMenu
@onready var save_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Save_Button
@onready var load_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Load_Button

@onready var margin_container = $MarginContainer as MarginContainer
@onready var music_stream_player = $MusicStreamPlayer
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var loading_page: Control = $loadingPage
@onready var saving_page: Control = $SavingPage
@onready var confirmation_dialog: Panel = $SavingPage/ConfirmationDialog

@onready var start_level = preload("res://scenes/UI/Narration/narration_ui.tscn") as PackedScene

var saving_slot_number := 1

func _ready()-> void:
	handle_connectin_signals()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _unhandled_input(event)-> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			hide()
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			show()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func on_start_pressed() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(start_level)

func on_option_pressed() -> void:
	margin_container.hide()
	options_menu.set_process(true)
	options_menu.show()

func on_save_btn_pressed() -> void:
	pass
	#SaveSystem._save()

func on_load_btn_pressed() -> void:
	SaveSystem.load_game()
	
func on_exit_pressed() -> void:
	get_tree().quit()
	

func on_exit_options_menu() -> void:
	margin_container.show()
	options_menu.hide()

func handle_connectin_signals() -> void:
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_option_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	save_button.button_down.connect(on_save_btn_pressed)
	load_button.button_down.connect(on_load_btn_pressed)
	
	
func _on_load_button_pressed() -> void:
	loading_page.show()


func _on_save_button_pressed() -> void:
	saving_page.show()
	

func _on_save_on_slot_1_pressed() -> void:
	saving_slot_number = 1
	confirmation_dialog.show()


func _on_save_on_slot_2_pressed() -> void:
	saving_slot_number = 2
	confirmation_dialog.show()


func _on_save_on_slot_3_pressed() -> void:
	saving_slot_number = 3
	confirmation_dialog.show()


func _on_button_confirm_save_pressed() -> void:
	SaveSystem.save_game(saving_slot_number)
	confirmation_dialog.hide()
	saving_page.hide()


func _on_button_cancel_save_pressed() -> void:
	saving_page.hide()
	confirmation_dialog.hide()
