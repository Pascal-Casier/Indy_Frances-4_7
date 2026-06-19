extends StaticBody3D

enum ui {QUIZZ, PHRASE}
@export var type : ui
@export var kill : bool = false
@export var door_nbr := -1
@onready var press_e: Sprite3D = %pressE

@onready var quizz: Control = $Quizz
@onready var phrase_maker_ui: CanvasLayer = $Phrase_maker_UI


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e.visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if type == ui.QUIZZ:
			quizz.show()
			quizz.z_index = 2
			phrase_maker_ui.layer = 0
		elif type == ui.PHRASE:
			phrase_maker_ui.show()
			phrase_maker_ui.layer = 2
			quizz.z_index = 0
		
func kill_me():
	if kill:
		$AnimationPlayer.play("disapear")
		await $AnimationPlayer.animation_finished
		queue_free()


func _on_quizz_success(index) -> void:
	if index == door_nbr:
		Global.open_door_gate.emit(door_nbr)
