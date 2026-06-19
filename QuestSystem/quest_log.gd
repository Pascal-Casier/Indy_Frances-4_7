extends Control

@onready var quest_list = %VBoxContainer

func _process(_delta):
	for i in quest_list.get_children():
		i.queue_free()
	for quest in QuestManager1.active_quests:
		var label = Label.new()
		label.text = quest.title
		quest_list.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_quest_log"):
		print_debug("show jornal")
		visible = !visible
	
		
