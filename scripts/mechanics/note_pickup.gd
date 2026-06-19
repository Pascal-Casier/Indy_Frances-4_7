extends Area3D

@export var signal_index : int = 1
@export_multiline var note_text : String
@export var sound : AudioStream

@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	if sound:
		%ButtonPlay.show()
	rich_text_label.text = note_text

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group('Player'):
		%Label3D.show()
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and %Label3D.visible:
		show_message()
func _on_button_pressed() -> void:
	%Control.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#monitoring = false
	Global.emit_spawn_signal(signal_index)
	Global.emit_open_door_gate(signal_index)

func show_message() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%Control.show()
	%Button.grab_focus()
	


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		%Label3D.hide()


func _on_button_play_pressed() -> void:
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()
