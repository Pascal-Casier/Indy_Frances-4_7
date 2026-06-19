extends ProgressBar

var fill_stylebox : StyleBoxFlat
const healthbar_colours = preload("res://assets/images/healthBarColours.tres")
var new_bar

func _ready() -> void:
	fill_stylebox = get_theme_stylebox("fill")
	value = 100
	new_bar = healthbar_colours.duplicate()
	fill_stylebox.bg_color = new_bar.gradient.sample(1 - max_value)

func _on_value_changed(new_value: float) -> void:
	new_bar = healthbar_colours.duplicate()
	fill_stylebox.bg_color = new_bar.gradient.sample(1 - (new_value / max_value))	
	
