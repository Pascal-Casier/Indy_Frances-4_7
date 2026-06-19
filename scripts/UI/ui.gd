extends Control

@export var is_visible : bool = true
@export var battery_icon_is_visible : bool = false
@export var potion_icon_is_visible : bool = true

@onready var progress_bar = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var coins_label = %Label
@onready var key_picture = $MarginContainer/HBoxContainer/KeyPicture
@onready var pause_menu = $Pause_menu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = %Timer
@onready var options_menu: MarginContainer = %options_menu
@onready var potion_icons_container: HBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2
@onready var battery_icons: HBoxContainer = $BatteryIcons


func _ready():
	if !is_visible:
		hide()
	Global.on_coins_updated.connect(on_coins_updated)
	Global.on_health_updated.connect(on_health_updated)
	Global.on_key_found.connect(on_key_updated)
	Global.on_keycard_found.connect(on_keycard_found)
	Global.emit_coins_updated()
	Global.emit_health_update()
	Global.emit_key_found()
	Global.light_on.connect(_on_light_lit)
	Global.full_battery.connect(_on_full_battery)
	%keycard.visible = Global.has_keycard
	if !battery_icon_is_visible:
		battery_icons.hide()
	if !potion_icon_is_visible:
		potion_icons_container.hide()
		
	#options_menu.connect("exit_options_menu", on_exit_options_btn_pressed)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible == false:
			pause_menu.show()
			#z_index = 8
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
		else:
			pause_menu.hide()
			z_index = -3
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false

func on_coins_updated(coins):
	var tween = get_tree().create_tween()
	tween.tween_property(%HBoxContainer, "size", Vector2(114, 150), 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(%HBoxContainer, "size", Vector2(114, 117), 0.2).set_trans(Tween.TRANS_BOUNCE)
	coins_label.text = str(coins)

func on_health_updated(value):
	progress_bar.value = value

func on_key_updated(has_key):
	key_picture.visible = has_key

func on_keycard_found():
	if Global.has_keycard:
		%keycard.show()
	else:
		%keycard.hide()
	
func _on_btn_options_pressed():
	get_tree().paused = false
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().reload_current_scene()
	


func _on_btnresume_pressed():
	pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func on_exit_options_btn_pressed():
	#options_menu.hide()
	pass

func _on_btn_menu_principal_pressed() -> void:
	pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	animation_player.play("fade_out")
	await animation_player.animation_finished
	Loader.chang_level("res://scenes/UI/main_menu.tscn")

func _on_light_lit(value : bool) -> void:
	if value == true:
		timer.start(1)
	elif value == false:
		timer.stop()
		

func _on_timer_timeout() -> void:
	%BatteryProgressBar.value -= 10
	if %BatteryProgressBar.value <= 0 :
		Global.can_light = false
		Global.lantern_off.emit()

func _on_full_battery() -> void:
	%BatteryProgressBar.value = 100


func _on_btnoptions_pressed() -> void:
	options_menu.show()


func _on_button_exit_pressed() -> void:
	options_menu.hide()
