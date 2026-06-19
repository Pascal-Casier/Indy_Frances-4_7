extends Node3D

@export_enum("TRAD", "KENNEY", "KENNEY_DETAIL") var wall_type
@export var door_number : int = -1
@export var can_interact : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var wall_trad: MeshInstance3D = $mesh_position/wall
@onready var kenny_wall: Node3D = $mesh_position/Kenny_wall
@onready var rock_wall: Node3D = $mesh_position/rock_wall

var open := false
var player_in_area : bool = false

func _ready() -> void:
	Global.open_door_gate.connect(open_big_gate)
	match  wall_type:
		0: 
			wall_trad.show()
			kenny_wall.hide()
			rock_wall.hide()
		1: 
			kenny_wall.show()
			wall_trad.hide()
			rock_wall.hide()
		2: 
			rock_wall.show()
			kenny_wall.hide()
			wall_trad.hide()
			
	
func open_big_gate(nb):
	if door_number == nb and not open:
		animation_player.play("open")
		
		open = true


func _on_secret_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		

func _on_secret_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		
func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact") and can_interact:
		animation_player.play("open")
		open = true
