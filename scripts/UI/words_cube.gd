extends Node3D
 
@export var phrase : String
@export var cube1 : Array[String]
@export var cube2 : Array[String]
@export var cube3 : Array[String]
@export var door_nbr := -1
@export var son : AudioStream

const CORRECT_ANSWER = preload("res://assets/sounds/sfx/click.wav")
const INCORRECT_2 = preload("res://assets/sounds/sfx/closed.wav")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite1: Sprite3D = %Sprite3D
@onready var sprite2: Sprite3D = %Sprite3D2
@onready var sprite3: Sprite3D = %Sprite3D3

var mecanisme_actif := true
var index := 0
var tween
var angle := 0
var angle2 := 0
var angle3 := 0

var player_entered := false

func _ready() -> void:
	sprite1.modulate = Color(0, 0, 0)
	sprite2.modulate = Color(0, 0, 0)
	sprite3.modulate = Color(0, 0, 0)
	for w in %cube1.get_children():
		w.text = cube1[index]
		index += 1
	
	index = 0
	for w in %cube2.get_children():
		w.text = cube2[index]
		index += 1
	
	index = 0
	for w in %cube3.get_children():
		w.text = cube3[index]
		index += 1

#var rotation_angle = 0
#
#func _process(delta):
	#if Input.is_action_pressed("fire"):
		#rotation_angle += 90
		#%cube1.transform = %cube1.transform.rotated(Vector3.RIGHT, deg_to_rad(rotation_angle))

#func _unhandled_input(event: InputEvent) -> void:
	#if not mecanisme_actif:
		#return
	#if event.is_action_pressed("ui_left") and player_entered:
		#angle +=90
		#if tween:
			#tween.kill()
		#tween = get_tree().create_tween()
		#tween.tween_property(%cube1, "rotation", Vector3(deg_to_rad(angle), 0, 0), .1)
		#tween.finished.connect(check_phrase)
	#if event.is_action_pressed("ui_up") and player_entered:
		#angle2 +=90
		#if tween:
			#tween.kill()
		#tween = get_tree().create_tween()
		#tween.tween_property(%cube2, "rotation", Vector3(deg_to_rad(angle2), 0, 0), 0.1)
		#tween.finished.connect(check_phrase)	
	#if event.is_action_pressed("ui_right") and player_entered:
		#angle3 +=90
		#if tween:
			#tween.kill()
		#tween = get_tree().create_tween()
		#tween.tween_property(%cube3, "rotation", Vector3(deg_to_rad(angle3), 0, 0), .1)
		#tween.finished.connect(check_phrase)	
func _unhandled_input(event: InputEvent) -> void:
	if not mecanisme_actif or not player_entered:
		return
	
	if event.is_action_pressed("ui_left"):
		angle += 90
		rotate_cube(%cube1, angle)
		
	elif event.is_action_pressed("ui_up"):
		angle2 += 90
		rotate_cube(%cube2, angle2)
		
	elif event.is_action_pressed("ui_right"):
		angle3 += 90
		rotate_cube(%cube3, angle3)

func rotate_cube(cube: Node3D, target_angle: float) -> void:
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property(cube, "rotation", Vector3(deg_to_rad(target_angle), 0, 0), 0.1)
	await tween.finished
	check_phrase()
	
	

func get_current_phrase() -> String:
	@warning_ignore("integer_division")
	var word1_index = int((angle / 90) % 4)
	@warning_ignore("integer_division")
	var word2_index = int((angle2 / 90) % 4)
	@warning_ignore("integer_division")
	var word3_index = int((angle3 / 90) % 4)
	
	var word1 = cube1[word1_index]
	var word2 = cube2[word2_index]
	var word3 = cube3[word3_index]
	
	# DEBUG : Affichez les angles et index
	print_debug("Cube1: angle=%d, index=%d, mot='%s'" % [angle, word1_index, word1])
	print_debug("Cube2: angle=%d, index=%d, mot='%s'" % [angle2, word2_index, word2])
	print_debug("Cube3: angle=%d, index=%d, mot='%s'" % [angle3, word3_index, word3])
	
	return "%s %s %s" % [word1, word2, word3]

func check_phrase() -> void:
	var current = get_current_phrase()
	print_debug("Phrase actuelle: ", current)
	
	if current == phrase:
		audio_stream_player.stream = CORRECT_ANSWER
		audio_stream_player.play()
		await audio_stream_player.finished
		audio_stream_player.stream = son
		audio_stream_player.play()
		await audio_stream_player.finished
		Global.emit_open_door_gate(door_nbr)
		mecanisme_actif = false
	else:
		audio_stream_player.stream = INCORRECT_2
		audio_stream_player.play()
#func check_phrase():
	#var current = get_current_phrase()
	#print_debug(current, get_current_phrase())
	#if current == phrase:
		#audio_stream_player.stream = CORRECT_ANSWER
		#audio_stream_player.play()
		#await audio_stream_player.finished
		#audio_stream_player.stream = son
		#audio_stream_player.play()
		#await audio_stream_player.finished
		#Global.emit_open_door_gate(door_nbr)
		#mecanisme_actif = false
	#else:
		#audio_stream_player.stream = INCORRECT_2
		#audio_stream_player.play()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group('Player') and mecanisme_actif:
		player_entered = true
		%contour.show()
		sprite1.modulate = Color(1, 1, 1)
		sprite2.modulate = Color(1, 1, 1)
		sprite3.modulate = Color(1, 1, 1)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group('Player'):
		player_entered = false
		%contour.hide()
		sprite1.modulate = Color(0, 0, 0)
		sprite2.modulate = Color(0, 0, 0)
		sprite3.modulate = Color(0, 0, 0)
