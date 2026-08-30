extends Area3D
class_name Stele_explications

@export var door_nbr : int = -1
## Liste des textes affichés, un par explication
@export_multiline var textes_array: Array[String] = []

## Liste des fichiers audio de narration, dans le même ordre que les textes
@export var narrations_array: Array[AudioStream] = []
@onready var explications_system: Control = $ExplicationsSystem
@onready var press_e_lbl: Label3D = %PressELbl
@onready var led_mesh_instance: MeshInstance3D = %LedMeshInstance


var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explications_system.textes = textes_array
	explications_system.narrations = narrations_array
	player = get_tree().get_first_node_in_group("Player")
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_lbl.visible:
		explications_system.show()
		if player:
			player.can_move = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if player:
			press_e_lbl.show()
			if led_mesh_instance :
				led_mesh_instance.show()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if player:
			press_e_lbl.hide()
			if led_mesh_instance :
				led_mesh_instance.hide()


func _on_explications_system_exit() -> void:
	if player:
		player.can_move = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Global.emit_open_door_gate(door_nbr)
