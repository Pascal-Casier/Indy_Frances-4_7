extends Control

@export var _is_visible : bool = true
@export var battery_icon_is_visible : bool = false
@export var potion_icon_is_visible : bool = true
@export var mots_trouves_is_visible : bool = true

@onready var progress_bar = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/ProgressBar
@onready var coins_label = %Label
@onready var key_picture = $MarginContainer/HBoxContainer/KeyPicture
@onready var pause_menu = $Pause_menu
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = %Timer
@onready var options_menu: MarginContainer = %options_menu
@onready var potion_icons_container: HBoxContainer = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2
@onready var battery_icons: HBoxContainer = $BatteryIcons
@onready var keycard = %keycard
@onready var hbox_container = %HBoxContainer
@onready var battery_progress_bar = %BatteryProgressBar
@onready var loading_page: Control = $loadingPage
@onready var container_mots_trouves: HBoxContainer = %HBoxContainerMots_trouves
@onready var lblmots_trouves_nbr: Label = %Lblmots_trouves_nbr


const BATTERY_DRAIN_RATE = 10
const COIN_ANIMATION_DURATION = 0.2
const COIN_BOUNCE_SIZE = Vector2(114, 150)
const COIN_NORMAL_SIZE = Vector2(114, 117)


func _ready() -> void:
	_initialize_visibility()
	_connect_signals()
	_emit_initial_states()
	Global.mots_trouves = []
	

func _initialize_visibility() -> void:
	visible = _is_visible
	battery_icons.visible = battery_icon_is_visible
	potion_icons_container.visible = potion_icon_is_visible
	keycard.visible = Global.has_keycard
	container_mots_trouves.visible = mots_trouves_is_visible

func _connect_signals() -> void:
	Global.on_coins_updated.connect(on_coins_updated)
	Global.on_health_updated.connect(on_health_updated)
	Global.on_key_found.connect(on_key_updated)
	Global.on_keycard_found.connect(on_keycard_found)
	Global.light_on.connect(_on_light_lit)
	Global.full_battery.connect(_on_full_battery)
	Global.words_found_number.connect(_on_new_word_found)


func _emit_initial_states() -> void:
	Global.emit_coins_updated()
	Global.emit_health_update()
	Global.emit_key_found()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause_menu()

func _on_new_word_found(nbr : int) ->void:
	lblmots_trouves_nbr.text = str(nbr) + "/" + str(Global.total_mots_attendus)
	
	
func _toggle_pause_menu() -> void:
	var is_paused = not pause_menu.visible
	pause_menu.visible = is_paused
	get_tree().paused = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED)


func on_coins_updated(coins: int) -> void:
	_animate_coin_collection()
	coins_label.text = str(coins)


func _animate_coin_collection() -> void:
	var tween = create_tween()
	tween.tween_property(hbox_container, "size", COIN_BOUNCE_SIZE, COIN_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(hbox_container, "size", COIN_NORMAL_SIZE, COIN_ANIMATION_DURATION).set_trans(Tween.TRANS_BOUNCE)


func on_health_updated(value: int) -> void:
	progress_bar.value = value


func on_key_updated(has_key: bool) -> void:
	key_picture.visible = has_key


func on_keycard_found() -> void:
	keycard.visible = Global.has_keycard


func _on_btn_options_pressed() -> void:
	await _fade_and_reload_scene()


func _on_btnresume_pressed() -> void:
	_close_pause_menu()


func _on_btn_menu_principal_pressed() -> void:
	_close_pause_menu()
	await _fade_out()
	Loader.chang_level("res://scenes/UI/main_menu.tscn")


func _close_pause_menu() -> void:
	pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _fade_out() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished


func _fade_and_reload_scene() -> void:
	get_tree().paused = false
	await _fade_out()
	get_tree().reload_current_scene()


func _on_light_lit(value: bool) -> void:
	if value:
		timer.start(1)
	else:
		timer.stop()


func _on_timer_timeout() -> void:
	battery_progress_bar.value -= BATTERY_DRAIN_RATE
	
	if battery_progress_bar.value <= 0:
		Global.can_light = false
		Global.lantern_off.emit()


func _on_full_battery() -> void:
	battery_progress_bar.value = 100


func _on_btnoptions_pressed() -> void:
	options_menu.show()


func _on_button_exit_pressed() -> void:
	options_menu.hide()


func _on_btnload_pressed() -> void:
	loading_page.show()
