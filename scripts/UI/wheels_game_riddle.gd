extends Control

signal success

@export var door_nbr : int = 0
@export var phrase_correcte : String
@export var list_words1 : Array[String]
@export var list_words2 : Array[String]
@export var list_words3 : Array[String]

@onready var cube_1: MeshInstance3D = %Cube1
@onready var cube_2: MeshInstance3D = %Cube2
@onready var cube_3: MeshInstance3D = %Cube3

var wheel_words : Array[Array]
var wheel_positions : Array = [0, 0, 0]

var index1 : int = 0
var index2 : int = 0
var index3 : int = 0

func _ready() -> void:
	wheel_words = [list_words1, list_words2, list_words3]
	for l in cube_1.get_children():
		l.text = list_words1[index1]
		index1 +=1
	for l in cube_2.get_children():
		l.text = list_words2[index2]
		index2 += 1
	for l in cube_3.get_children():
		l.text = list_words3[index3]
		index3 += 1

	for b in get_tree().get_nodes_in_group("button"):
		b.pressed.connect(play_sound)
		

func rotate(mesh, distance, wheel_index, direction):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh, "rotation", mesh.rotation + Vector3(0, deg_to_rad(distance), 0), 1.1)
	if direction == "clockwise":
		wheel_positions[wheel_index] += 1
	else:
		wheel_positions[wheel_index] -= 1
	check_phrase()
	
func check_phrase():
	var current_phrase = ""
	for i in range(wheel_words.size()):
		var aligned_word_index = (wheel_positions[i] + wheel_words[i].size()) % wheel_words[i].size()
		current_phrase += wheel_words[i][aligned_word_index] + " "
	
	if current_phrase == phrase_correcte:
		await get_tree().create_timer(1.1).timeout
		%AudioStreamPlayer2.play()
		Global.emit_open_door_gate(door_nbr)
		await get_tree().create_timer(1.1).timeout
		queue_free()
		success.emit()

	

func play_sound():
	%AudioStreamPlayer.play()
	for b in get_tree().get_nodes_in_group("button"):
		b.disabled = true
	await get_tree().create_timer(1.1).timeout
	for b in get_tree().get_nodes_in_group("button"):
		b.disabled = false
	

func _on_button_1l_pressed() -> void:
	rotate(cube_1,-60, 0, "clockwise")


func _on_button_2l_pressed() -> void:
	rotate(cube_2, -60, 1, "clockwise") # Replace with function body.


func _on_button_3l_pressed() -> void:
	rotate(cube_3, -60, 2, "clockwise")


func _on_buttondr_pressed() -> void:
	rotate(cube_1, 60, 0, "")


func _on_button_2_dr_pressed() -> void:
	rotate(cube_2, 60, 1, "")


func _on_button_3_dr_pressed() -> void:
	rotate(cube_3, 60, 2, "")


func _on_button_exit_pressed() -> void:
	hide()
