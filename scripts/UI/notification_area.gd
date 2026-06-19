extends Area3D

@export_multiline var notification := "test"
@export var kill := false
@onready var label: Label = %Label
@onready var control: Control = $CanvasLayer/Control

@export var npc_id: String = "paul_npc"
@export var quest_to_give: Quest # assigner `talk_to_npc1.tres` dans l’inspecteur

func _ready() -> void:
	label.text = notification

func pop_up() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(control, "position", Vector2(576, 600), 0.2).set_ease(Tween.EASE_IN_OUT)
	
func pop_down() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(control, "position", Vector2(576, 780), 0.2).set_ease(Tween.EASE_IN_OUT)
	if kill:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		pop_up()
		
		if quest_to_give:
			QuestManager1.add_quest(quest_to_give)
			#QuestManager1.complete_quest(npc_id)
			print_debug(quest_to_give.title, npc_id)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		pop_down()
		
