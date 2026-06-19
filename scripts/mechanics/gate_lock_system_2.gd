extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var press_elbl: Label3D = $ordinateur1/Cube/pressElbl
@onready var ordinateur_1: Area3D = $ordinateur1
@onready var contour: MeshInstance3D = $ordinateur1/Cube/contour
@onready var player = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_elbl.visible:
		ordinateur_1.monitoring = false
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$quizz_vocabulaire.show()

func _on_quizz_vocabulaire_success(value) -> void:
	if value == "yes":
		animation_player.play("open_gate")
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else :
		if player and player.has_method("hit"):
			player.hit()


func _on_ordinateur_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.show()
		contour.show()


func _on_ordinateur_1_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_elbl.hide()
		contour.hide()
