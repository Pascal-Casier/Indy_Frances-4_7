extends Control

@onready var audio_player: AudioStreamPlayer = %AudioPlayer
@onready var buttons_container: GridContainer = %buttons_container
@onready var chapters_container: NinePatchRect = %Chapters_container
@onready var background_1: MarginContainer = %Background1
@onready var background_2: MarginContainer = %Background2

var button_list = []
var stream_list = {
	"chapt1_1" : preload("res://assets/sounds/inventory_sounds/cap1_1.mp3"),
	"chapt1_2" : preload("res://assets/sounds/inventory_sounds/cap1_2.mp3"),
	"chapt1_3" : preload("res://assets/sounds/inventory_sounds/cap1_3.mp3"),
	"chapt1_4" : preload("res://assets/sounds/inventory_sounds/cap1_4.mp3"),
	"chapt1_5" : preload("res://assets/sounds/inventory_sounds/cap1_5.mp3"),
	"chapt1_6" : preload("res://assets/sounds/inventory_sounds/cap1_6.mp3"),
	"chapt2_1" : preload("res://assets/sounds/inventory_sounds/cap2_1.mp3"),
	"chapt2_2" : preload("res://assets/sounds/inventory_sounds/cap2_2.mp3"),
	"chapt2_3" : preload("res://assets/sounds/inventory_sounds/cap2_3.mp3"),
	"chapt2_4" : preload("res://assets/sounds/inventory_sounds/cap2_4.mp3"),
	"chapt2_5" : preload("res://assets/sounds/inventory_sounds/cap2_5.mp3"),
	"chapt2_6" : preload("res://assets/sounds/inventory_sounds/cap2_6.mp3"),
	"chapt2_7" : preload("res://assets/sounds/inventory_sounds/cap2_7.mp3"),
	"chapt2_8" : preload("res://assets/sounds/inventory_sounds/cap2_8.mp3"),
	"chapt2_9" : preload("res://assets/sounds/inventory_sounds/cap2_9.mp3"),
	"chapt2_10" : preload("res://assets/sounds/inventory_sounds/cap2_10.mp3"),
	"chapt2_11" : preload("res://assets/sounds/inventory_sounds/cap2_11.mp3"),
	"chapt3_1" : preload("res://assets/sounds/inventory_sounds/cap3_1.mp3"),
	"chapt3_2" : preload("res://assets/sounds/inventory_sounds/cap3_2.mp3"),
	"chapt3_3" : preload("res://assets/sounds/inventory_sounds/cap3_3.mp3"),
	"chapt3_4" : preload("res://assets/sounds/inventory_sounds/cap3_4.mp3"),
	"chapt3_5" : preload("res://assets/sounds/inventory_sounds/cap3_5.mp3"),
	"chapt3_6" : preload("res://assets/sounds/inventory_sounds/cap3_6.mp3"),
	"chapt3_7" : preload("res://assets/sounds/inventory_sounds/cap3_7.mp3"),
	"chapt3_8" : preload("res://assets/sounds/inventory_sounds/cap3_8.mp3"),
	"chapt3_9" : preload("res://assets/sounds/inventory_sounds/cap3_1.mp3"),
	"chapt3_10" : preload("res://assets/sounds/inventory_sounds/cap3_10.mp3"),
	"chapt3_11" : preload("res://assets/sounds/inventory_sounds/cap3_11.mp3"),
	"chapt3_12" : preload("res://assets/sounds/inventory_sounds/cap3_12.mp3"),
	"chapt3_13" : preload("res://assets/sounds/inventory_sounds/cap3_13.mp3"),
	"chapt3_14" : preload("res://assets/sounds/inventory_sounds/cap3_14.mp3"),
	"chapt3_15" : preload("res://assets/sounds/inventory_sounds/cap3_15.mp3"),
	"chapt3_16" : preload("res://assets/sounds/inventory_sounds/cap3_16.mp3"),
	"chapt4_1" : preload("res://assets/sounds/inventory_sounds/cap4_1.mp3"),
	"chapt4_2" : preload("res://assets/sounds/inventory_sounds/cap4_2.mp3"),
	"chapt4_3" : preload("res://assets/sounds/inventory_sounds/cap4_3.mp3"),
	"chapt4_4" : preload("res://assets/sounds/inventory_sounds/cap4_4.mp3"),
	"chapt4_5" : preload("res://assets/sounds/inventory_sounds/cap4_5.mp3"),
	"chapt4_6" : preload("res://assets/sounds/inventory_sounds/cap4_6.mp3"),
	"chapt4_7" : preload("res://assets/sounds/inventory_sounds/cap4_7.mp3"),
	"chapt4_8" : preload("res://assets/sounds/inventory_sounds/cap4_8.mp3"),
	"chapt9_1" : preload("res://assets/sounds/inventory_sounds/cap9_1.mp3")
}

func _ready() -> void:
	Global.on_new_book_found.connect(add_one_chapter)
	button_list = buttons_container.get_children()
	for b in button_list:
		b.pressed.connect(on_chapter_nbr_btn_pressed.bind(b.name))
	for t in get_tree().get_nodes_in_group("Label"):
		t.meta_clicked.connect(on_audio_icon_pressed)

func add_one_chapter():
	#if Global.book_lesson_number < 12 and Global.book_lesson_number != 0:
		#button_list[Global.book_lesson_number-1].visible = true
	buttons_container.show()


func on_chapter_nbr_btn_pressed(chapter):
	background_2.show()
	for c in chapters_container.get_children():
		if c.name == chapter:
			c.show()
		else: c.hide()
		%ButtonExit.show()

func on_audio_icon_pressed(meta):
	if audio_player.playing and audio_player.stream == stream_list[meta]:
		audio_player.stop()
	else:
		audio_player.stream = stream_list[meta]
		audio_player.play()
		

func _on_btn_exit_chapter_pressed() -> void:
	background_2.hide()

#func _on_button_exit_pressed() -> void:
	#print_debug("sortir")
	#hide()
	##Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	##get_tree().paused = false
