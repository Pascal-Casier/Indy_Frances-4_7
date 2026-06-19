extends Sprite3D

signal no_hp_left

@onready var progress_bar: ProgressBar = $SubViewport/Panel/ProgressBar
var real_value : float
@export var max_hp := 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_bar.value = max_hp
	progress_bar.max_value = max_hp
	real_value = max_hp

func take_damage(damage : float):
	real_value -= damage
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", real_value, 0.3)
	if progress_bar.value <= 0.1:
		no_hp_left.emit()
