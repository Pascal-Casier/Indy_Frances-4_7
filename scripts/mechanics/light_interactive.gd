extends Node3D

@export var is_on : bool = true
@export var door_nbr : int = -1
@export var _range : int = 8
@export_color_no_alpha var light_couleur

@onready var omni_light_3d: OmniLight3D = $OmniLight3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	omni_light_3d.omni_range = _range
	omni_light_3d.light_color = light_couleur
	if is_on :
		omni_light_3d.show()
	else:
		omni_light_3d.hide()
	Global.open_door_gate.connect(light_on)


func light_on(nbr) -> void:
	if door_nbr == nbr:
		omni_light_3d.show()
