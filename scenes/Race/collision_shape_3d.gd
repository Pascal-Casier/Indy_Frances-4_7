extends Area3D

@export var grip_multiplier: float = 0.3   # 1.0 = adhérence normale, plus bas = plus glissant
@export var friction_value: float = 0.05   # frottement physique dans la flaque

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	# "ball" est enfant direct du noeud Jeep
	if body.get_parent() is Jeep2:
		body.get_parent().set_grip(grip_multiplier, friction_value)

func _on_body_exited(body: Node) -> void:
	if body.get_parent() is Jeep2:
		#await get_tree().create_timer(1.5).timeout
		body.get_parent().reset_grip()
