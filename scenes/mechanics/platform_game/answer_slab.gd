class_name AnswerSlab
extends Area3D

signal confirmed(slab: AnswerSlab)

@export var label: Label3D
@export var confirm_time: float = 0.8
@export var text_width_meters: float = 2.4
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var answer_index: int = -1

var _player_inside: bool = false
var _elapsed: float = 0.0
var _active: bool = true
var _locked_until_exit: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.width = text_width_meters / label.pixel_size


func set_answer(text: String, index: int) -> void:
	answer_index = index
	if label:
		label.text = text


func set_active(value: bool) -> void:
	_active = value
	_elapsed = 0.0
	if value and _player_inside:
		_locked_until_exit = true

	# Désactive ou active la collision de manière différée
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", !value)


func _physics_process(delta: float) -> void:
	if not _active or not _player_inside or _locked_until_exit:
		return
	_elapsed += delta
	if _elapsed >= confirm_time:
		_elapsed = 0.0
		confirmed.emit(self)


func _on_body_entered(body: Node3D) -> void:
	if _active and body is CharacterBody3D:
		_player_inside = true
		_elapsed = 0.0
		if animation_player and animation_player.has_animation("down"):
			animation_player.play("down")


func _on_body_exited(body: Node3D) -> void:
	if _active and body is CharacterBody3D:
		_player_inside = false
		_locked_until_exit = false
		_elapsed = 0.0
		if animation_player and animation_player.has_animation("up"):
			animation_player.play("up")
