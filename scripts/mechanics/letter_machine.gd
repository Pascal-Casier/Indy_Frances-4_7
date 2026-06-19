extends Node3D


@export var cube : PackedScene
var new_letter : String
@export var count : int = 10
@onready var control: Control = %Control
@onready var line_edit: LineEdit = %LineEdit
@onready var counterlbl: Label3D = %counterlbl
@onready var animation_player: AnimationPlayer = %AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_edit.grab_focus()
	counterlbl.text = str(count)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and %pressE.visible:
		if count > 0:
			count -= 1
			%counterlbl.text = str(count)
			%Control.show()
			%LineEdit.text = ""
			%LineEdit.grab_focus()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
		else:
			%AudioStreamempty.play()
	if Input.is_action_just_pressed("interact") and %labelKeycard.visible and Global.has_keycard:
		count += 10
		%counterlbl.text = str(count)
		%AudioStreamkeyentered.play()
		animation_player.play("keyentered")
		Global.has_keycard = false
		Global.emit_signal("on_keycard_found")
		
func _on_area_btn_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%pressE.hide()

func spwan_cube(letterX):
	var new_cube = cube.instantiate()
	new_cube.position = %Marker3D.global_position
	new_cube.letter = letterX
	get_tree().get_root().add_child(new_cube)

func _on_line_edit_text_submitted(new_text: String) -> void:
	%AudioStreamMAchine.play()
	%Control.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#new_text = new_text.to_upper()
	await get_tree().create_timer(2.68).timeout
	spwan_cube(new_text)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%pressE.show()


func _on_area_keycard_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%labelKeycard.show()


func _on_area_keycard_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%labelKeycard.hide()
