class_name ButtonQuest extends Button

@onready var lbl_quest_titlebtn: Label = $lblQuestTitlebtn
@onready var lbl_quest_statebtn: Label = $lblQuestStatebtn

var quest : Quest

func initialize(q: Quest) -> void:
	quest = q
	print_debug("nouvelle quelet" + q.title)
	lbl_quest_titlebtn.text = q.title
	if q.is_completed:
		lbl_quest_statebtn.text = "terminée ✅"
	else:
		lbl_quest_statebtn.text = "en cours..."
	pass
