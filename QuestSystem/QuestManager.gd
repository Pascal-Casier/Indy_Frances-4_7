# scripts/quest_manager.gd
extends Node
class_name QuestManager

var active_quests: Array[Quest] = []

func add_quest(quest: Quest):
	if !active_quests.has(quest):
		active_quests.append(quest)

func complete_quest(target_id: String):
	for quest in active_quests:
		if !quest.is_completed and quest.target_id == target_id:
			quest.is_completed = true
			print_debug("Quête terminée : ", quest.title)
