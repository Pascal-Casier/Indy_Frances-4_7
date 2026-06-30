extends Control

@onready var time_lbl: Label = %TimeLbl
@onready var word_lbl: Label = %WordLbl
@onready var score_lbl: Label = %ScoreLbl

@export var questions_list : Array[String]
@export var answers_list : Array[String]

var index : int = 0

func _ready() -> void:
	word_lbl.text = questions_list[index]
