class_name QuestUI extends MarginContainer

const QUEST_BTN : PackedScene = preload("res://QuestSystem/button_quest.tscn")
@onready var quest_btns_container: VBoxContainer = %VBoxContainer

@onready var lbl_quest_title: Label = %lblQuestTitle
@onready var lbl_quest_description: Label = %lblQuestDescription


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	for i in quest_btns_container.get_children():
		i.queue_free()
	if visible:
		for q in QuestManager1.active_quests:
			var new_btn_quest = QUEST_BTN.instantiate()
			quest_btns_container.add_child(new_btn_quest)
			new_btn_quest.initialize(q)
			new_btn_quest.pressed.connect(_on_quest_btn_pressed.bind(q))

func _on_quest_btn_pressed(q : Quest)-> void:
	print_debug(q.title, q.description)
	lbl_quest_title.text = q.title
	lbl_quest_description.text = q.description
	pass
