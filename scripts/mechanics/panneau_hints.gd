extends StaticBody3D

@onready var lbl_press_e: Label3D = $"3D_button/PressE"
@export var hints : Array[String]
@onready var lbl_conseil: Label3D = $Cube/lblConseil

var index := 0

func _process(_delta: float) -> void:
	if lbl_press_e.visible:
		if Input.is_action_just_pressed("interact"):
			$AnimationPlayer.play("on")
			lbl_conseil.text = hints[index]
			index += 1%hints.size()
			

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.show()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		lbl_press_e.hide()
