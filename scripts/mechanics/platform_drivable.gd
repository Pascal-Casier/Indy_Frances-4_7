class_name QuizPlatform
extends AnimatableBody3D

signal answered(correct: bool)
signal goal_reached

@export var questions: Array[QuizQuestion] = []
@export var goal: Marker3D
@export var steps_to_goal: int = 0
@export var wrong_steps_back: int = 1

@export_group("Nodes")
@export var question_label: Label3D
@export var feedback_label: Label3D
@export var slabs: Array[AnswerSlab] = []
## Interrupteur pour déclencher les trajets Aller/Retour (Area3D / PlatformSwitch)
@export var travel_switch: PlatformSwitch

@export_group("Timing")
@export var move_duration: float = 1.2
@export var feedback_duration: float = 1.5

@export_group("Texte")
@export var correct_text: String = "Bonne réponse !"
@export var wrong_text: String = "Mauvaise réponse..."
@export var idle_text: String = "Placez-vous sur une dalle"
@export var finished_text: String = "Bravo, vous êtes arrivé !"
@export var traveling_text: String = "Déplacement en cours..."

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const CORRECT_SOUND = preload("uid://born1mix6seh0")
const INCORRECT_SOUND = preload("uid://drqgwjmv3iqc1")
const METAL_CLICK = preload("uid://on8ir7nf7sub")

var _start_position: Vector3
var _step_vector: Vector3
var _steps_total: int = 0
var _steps_done: int = 0
var _pool: Array[QuizQuestion] = []
var _current: QuizQuestion
var _busy: bool = false
var _destination_unlocked: bool = false


func _ready() -> void:
	sync_to_physics = true

	if questions.is_empty() or goal == null or slabs.is_empty():
		push_warning("QuizPlatform: questions, goal ou slabs non configurés.")
		return

	_start_position = global_position
	_steps_total = steps_to_goal if steps_to_goal > 0 else questions.size()
	_step_vector = (goal.global_position - _start_position) / float(_steps_total)

	for slab in slabs:
		slab.confirmed.connect(_on_slab_confirmed)

	if travel_switch:
		travel_switch.is_active = false
		travel_switch.toggled.connect(_on_travel_switch_toggled)

	_show_next_question()


func _next_question() -> QuizQuestion:
	if _pool.is_empty():
		_pool = questions.duplicate()
		_pool.shuffle()
		if _pool.size() > 1 and _pool.back() == _current:
			_pool.reverse()
	return _pool.pop_back()


func _show_next_question() -> void:
	# Si le trajet libre est débloqué, on n'affiche plus les questions
	if _destination_unlocked:
		return

	_current = _next_question()
	question_label.text = _current.text
	feedback_label.text = idle_text

	var order: Array = range(mini(slabs.size(), _current.answers.size()))
	order.shuffle()
	for i in slabs.size():
		if i < order.size():
			slabs[i].set_answer(_current.answers[order[i]], order[i])
		else:
			slabs[i].set_answer("", -1)
		slabs[i].set_active(true)

	_busy = false


func _on_slab_confirmed(slab: AnswerSlab) -> void:
	if _busy:
		return
	_busy = true
	for s in slabs:
		s.set_active(false)

	var correct := slab.answer_index == _current.correct_index
	feedback_label.text = correct_text if correct else wrong_text
	if _current.explanation != "":
		feedback_label.text += "\n" + _current.explanation
	answered.emit(correct)

	var previous_steps := _steps_done
	if correct:
		_steps_done += 1
		audio_stream_player.stream = CORRECT_SOUND
		audio_stream_player.play()
	else:
		_steps_done = maxi(0, _steps_done - wrong_steps_back)
		audio_stream_player.stream = INCORRECT_SOUND
		audio_stream_player.play()

	if _steps_done != previous_steps:
		var target := _start_position + _step_vector * _steps_done
		await _move_to_position(target)

	if _steps_done >= _steps_total:
		_destination_unlocked = true
		question_label.text = ""
		feedback_label.text = finished_text

		for s in slabs:
			s.visible = false
			s.set_active(false)

		if travel_switch:
			travel_switch.is_active = true # Activera la visibilité ET la collision

		goal_reached.emit()
		_busy = false
		return

	await get_tree().create_timer(feedback_duration).timeout
	_show_next_question()


## Trajet Aller/Retour déclenché par l'interrupteur
func _on_travel_switch_toggled() -> void:
	if _busy or not _destination_unlocked:
		return
	_busy = true
	audio_stream_player.stream = METAL_CLICK
	audio_stream_player.play()

	# Si la plateforme est plus proche du départ, la destination cible est le but (et inversement)
	var is_near_start := global_position.distance_to(_start_position) < global_position.distance_to(goal.global_position)
	var target := goal.global_position if is_near_start else _start_position

	feedback_label.text = traveling_text
	
	# Mouvement sur la totalité du trajet (durée ajustée proportionnellement au trajet complet)
	await _move_to_position(target, move_duration * 2.0)

	_steps_done = _steps_total if is_near_start else 0
	feedback_label.text = finished_text if is_near_start else "Retour au départ."
	_busy = false


## Fonction utilitaire pour gérer le Tween de déplacement
func _move_to_position(target: Vector3, custom_duration: float = -1.0) -> void:
	var duration := move_duration if custom_duration <= 0.0 else custom_duration
	var tween := create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position", target, duration)
	await tween.finished
