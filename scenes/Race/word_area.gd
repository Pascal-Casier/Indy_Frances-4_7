extends MeshInstance3D

signal word_name
@export var fr_word : String
@export var por_traducao : String

@onready var label_3d: Label3D = $Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3d.text = por_traducao
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
