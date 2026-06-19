extends Node

var loading_screen = load("res://scenes/UI/scene_loader_1.tscn")
var scene_path : String

func chang_level(path):
	scene_path = path
	get_tree().change_scene_to_packed(loading_screen)
