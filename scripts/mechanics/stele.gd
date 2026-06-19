extends Area3D

@export_multiline var texte : String 
@onready var press_e_lbl: Label3D = %PressELbl
@onready var control: Control = %Control
@export var led : Node3D
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var tween_actuel: Tween = null
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	rich_text_label.text = texte
	control.scale = Vector2.ZERO
	control.modulate.a = 0
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_lbl.visible:
		control.show()
		if control.get_child_count() > 0:
			control.get_child(0).show()
			slide_in_from_bottom()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if player:
				player.can_move = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				slide_in_from_bottom()
				

func _on_area_3d_body_entered(_body: Node3D) -> void:
	if _body.is_in_group("Player"):
		if player:
			press_e_lbl.show()
			if led :
				led.show()


func _on_area_3d_body_exited(_body: Node3D) -> void:
	if _body.is_in_group("Player"):
		if player:
			press_e_lbl.hide()
			if led :
				led.hide()


func _on_button_ok_pressed() -> void:
	if player:
		player.can_move = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		disparaitre_avec_zoom()
		
		
func slide_in_from_bottom(_duration := 0.5):
	# Tuer le tween précédent s'il existe
	@warning_ignore("confusable_local_usage")
	if tween_actuel:
		@warning_ignore("confusable_local_usage")
		tween_actuel.kill()
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2.ZERO
	control.modulate.a = 0
	@warning_ignore("shadowed_variable")
	var tween_actuel = create_tween()
	# Animer le scale de 0 à 1
	tween_actuel.tween_property(control, "scale", Vector2.ONE, 0.3)
	# Optionnel : animer aussi l'opacité pour un effet plus fluide
	tween_actuel.parallel().tween_property(control, "modulate:a", 1.0, 0.3)
	# Optionnel : ajouter un effet d'élasticité
	tween_actuel.set_ease(Tween.EASE_OUT)
	tween_actuel.set_trans(Tween.TRANS_BOUNCE)

func disparaitre_avec_zoom():
	# Tuer le tween précédent s'il existe
	if tween_actuel:
		tween_actuel.kill()
	
	# Créer un nouveau Tween pour disparaître
	tween_actuel = create_tween()
	
	# Animer vers 0
	tween_actuel.tween_property(control, "scale", Vector2.ZERO, 0.2)
	tween_actuel.parallel().tween_property(control, "modulate:a", 0.0, 0.2)
	tween_actuel.set_ease(Tween.EASE_IN)
	await tween_actuel.finished
	control.hide()
