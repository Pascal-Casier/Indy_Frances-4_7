extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/FinalScore
@onready var restart_button: Button = $GameOverPanel/RestartButton

func _ready() -> void:
	game_over_panel.visible = false
	restart_button.pressed.connect(_on_restart)

func update_score(value: int) -> void:
	score_label.text = "Score : %d" % value

func show_game_over(final: int) -> void:
	game_over_panel.visible = true
	final_score_label.text = "Score final : %d" % final

func _on_restart() -> void:
	get_tree().reload_current_scene()
