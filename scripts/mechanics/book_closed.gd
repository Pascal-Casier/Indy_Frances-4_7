extends Area3D

var speed = 5.0
var player = null
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var button_ok: Button = %ButtonOK
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	button_ok.grab_focus()
func _process(delta: float) -> void:
	$spellbook_closed.rotation.y += speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Global.emit_on_new_book_found_signal()
		#Global.GameMode.READING
		$AudioStreamPlayer.play()
		$spellbook_closed.hide()
		$CollisionShape3D.disabled = true
		$GPUParticles3D.hide()
		$GPUParticles3D2.hide()
		player = body
		get_tree().paused = true
		player.can_move = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		animation_player.play("open")
		canvas_layer.show()


func _on_button_ok_pressed() -> void:
	animation_player.play_backwards("open")
	await animation_player.animation_finished
	Global.mode = Global.GameMode.PLAY
	get_tree().paused = false
	player.can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	queue_free()
