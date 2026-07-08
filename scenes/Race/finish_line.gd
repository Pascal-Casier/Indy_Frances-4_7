extends Area3D
class_name FinishLine

signal jeu_termine(victoire: bool, score_pourcent: float)

@export var next_scene: String
@onready var message_lbl: Label = %messageLbl
@onready var audio_finish: AudioStreamPlayer = $AudioFinish

const SEUIL_REUSSITE: float = 0.70

var bonnes_reponses: int = 0
var total_portails: int = 0
var _armed := false

func _ready() -> void:
	$AnimationPlayer.play("fade_in")
	body_entered.connect(_on_body_entered)
	_connecter_portails()

	# Anti-faux-départ si la finish line = ligne de départ
	await get_tree().create_timer(1.0).timeout
	_armed = true

func _connecter_portails() -> void:
	bonnes_reponses = 0
	total_portails = 0
	for p in get_tree().get_nodes_in_group("portails"):
		p.repondu.connect(_on_portail_repondu)
		total_portails += 1

func _on_portail_repondu(correct: bool) -> void:
	if correct:
		bonnes_reponses += 1

func _on_body_entered(body: Node3D) -> void:
	if not _armed: return
	if body.get_parent() is Jeep2:
		body.get_parent().stop()
		
		end_race(body.get_parent().time_left)
		
func end_race(time_left : float) -> void:
	var score := float(bonnes_reponses) / float(total_portails) if total_portails > 0 else 0.0
	var victoire := score >= SEUIL_REUSSITE
	jeu_termine.emit(victoire, score)
	message_lbl.text = "Score : " + str(int(score * 100)) + "%"
	%timelbl.text = "Temps retant: %.2f" % time_left
	if time_left > 0.0 and victoire:
		%ButtonExit.text = "Continuer..."
	else:
		%ButtonExit.text = "Recommencer"
	$CanvasLayer.show()
	audio_finish.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_button_exit_pressed() -> void:
	if %ButtonExit.text == "Continuer...":
		$CanvasLayer.hide()
		$AnimationPlayer.play("fade_out")
		await $AnimationPlayer.animation_finished
		Loader.chang_level(next_scene)
	else:
		$CanvasLayer.hide()
		$AnimationPlayer.play("fade_out")
		await $AnimationPlayer.animation_finished
		get_tree().reload_current_scene()
