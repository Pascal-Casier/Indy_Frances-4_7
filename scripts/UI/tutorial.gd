extends CanvasLayer

var tuto_visible := false

func _ready() -> void:
	Global.show_tuto.connect(show_tuto)

func show_tuto(value : bool) -> void:
	if value:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play("hide")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		if tuto_visible:
			$AnimationPlayer.play("hide")
			tuto_visible = false
		else:
			$AnimationPlayer.play("show")
			tuto_visible = true
		
