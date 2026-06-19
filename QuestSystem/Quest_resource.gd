# scripts/quest.gd
extends Resource
class_name Quest
@export var title: String
@export var description: String
@export var is_completed: bool = false
@export var goal_type: String = "talk_to_npc" # ou "collect", "kill", etc.
@export var target_id: String = "" # ID de l'objet ou du NPC
