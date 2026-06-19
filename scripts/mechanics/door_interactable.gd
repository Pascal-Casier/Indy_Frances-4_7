extends Node3D

@export var need_key : bool = false
var is_open: bool = false
@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player = $AudioStreamPlayer
@onready var label_3d = $wall_doorway_door/Label3D
@onready var pressE: Label = $Control/Label

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and !is_open:
		pressE.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player") and !is_open:
		pressE.hide()
		label_3d.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and pressE.visible and !is_open:
		if Global.has_key or !need_key:
			animation_player.play("open_door")
			is_open = true
			label_3d.hide()
			pressE.hide()
		else:
			label_3d.show()
			animation_player.play("shake")
			
