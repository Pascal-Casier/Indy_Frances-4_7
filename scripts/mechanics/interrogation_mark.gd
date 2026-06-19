extends Area3D

@export var dialog_name : String = "tuto1"
@export var kill : bool = true
var speed = 5.0
var player : CharacterBody3D = null

func _process(delta):
	$Label3D.rotation.y += speed * delta


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player.can_move = false
		#if kill:
			#$CollisionShape3D.disabled = true

		Dialogic.start(dialog_name)
		get_viewport().set_input_as_handled()	
		player.set_physics_process(false)
		if Dialogic.current_timeline != null:
			return
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		#Dialogic.start(dialog_name)
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#Global.pausing = true
		#Global.emit_on_pause_mode()
		#get_viewport().set_input_as_handled()

func _on_timeline_ended():
	player.set_physics_process(true)
	player.can_move = true
	player = null
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Global.pausing = false
	#Global.emit_on_pause_mode()
	if kill :
		queue_free()
	
