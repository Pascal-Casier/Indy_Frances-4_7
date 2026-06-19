extends HSlider

@onready var nbr: Label = %nbr

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nbr.text = str(value)


func _on_value_changed(_value: float) -> void:
	nbr.text = str(_value)
	Global.mouse_sensitiv = value
