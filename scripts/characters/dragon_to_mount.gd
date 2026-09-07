extends Area3D

@onready var label_3d: Label3D = $Label3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var player : CharacterBody3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d.show()
		player = body

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		label_3d.hide()
		player = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and label_3d.visible:
		if player :
			player.can_move = false
		animation_player.play("fade_out")
		await animation_player.animation_finished
		canvas_layer.show()
		animation_player.play("fade")
		await animation_player.animation_finished
		player.can_move = true
		Loader.chang_level("res://scenes/levels/3test.tscn")
	
