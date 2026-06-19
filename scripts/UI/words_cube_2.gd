extends Node3D

@export var phrase: String
@export var words1: Array[String]
@export var words2: Array[String]
@export var words3: Array[String]
@export var door_nbr := -1
@export var success_sound: AudioStream
@export var fail_sound: AudioStream

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@onready var col1_rot: Node3D = $Column1/Rotator
@onready var col2_rot: Node3D = $Column2/Rotator
@onready var col3_rot: Node3D = $Column3/Rotator

@onready var col1_label: Label3D = $Column1/Label3D
@onready var col2_label: Label3D = $Column2/Label3D
@onready var col3_label: Label3D = $Column3/Label3D

var index1 := 0
var index2 := 0
var index3 := 0

var rotation_speed := 0.15
var mecanisme_actif := true
var player_entered := false

func _ready():
	update_visuals()

func _unhandled_input(event: InputEvent):
	if not mecanisme_actif or not player_entered:
		return

	if event.is_action_pressed("ui_left"):
		rotate_column(1)

	elif event.is_action_pressed("ui_up"):
		rotate_column(2)

	elif event.is_action_pressed("ui_right"):
		rotate_column(3)


func rotate_column(col: int):
	match col:
		1:
			index1 = wrapi(index1 + 1, 0, words1.size())
			animate_rotation(col1_rot)
		2:
			index2 = wrapi(index2 + 1, 0, words2.size())
			animate_rotation(col2_rot)
		3:
			index3 = wrapi(index3 + 1, 0, words3.size())
			animate_rotation(col3_rot)

	update_visuals()
	check_phrase()


func animate_rotation(rotator: Node3D):
	var tw = create_tween()
	tw.tween_property(rotator, "rotation_degrees", rotator.rotation_degrees + Vector3(90, 0, 0), rotation_speed)


func update_visuals():
	col1_label.text = words1[index1]
	col2_label.text = words2[index2]
	col3_label.text = words3[index3]


func get_current_phrase() -> String:
	return "%s %s %s" % [
		words1[index1],
		words2[index2],
		words3[index3]
	]


func check_phrase():
	var current = get_current_phrase()

	if current == phrase:
		mecanisme_actif = false
		audio.stream = success_sound
		audio.play()
		#await audio.finished
		Global.emit_open_door_gate(door_nbr)
		$Area3D.monitoring = false
	else:
		audio.stream = fail_sound
		audio.play()


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		player_entered = true
		%Contour.show()
		%lever_place.show()

func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		player_entered = false
		%Contour.hide()
		%lever_place.hide()
