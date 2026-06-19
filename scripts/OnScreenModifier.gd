extends Node3D

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	self.show()
	

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	self.hide()
	


func _on_visible_on_screen_notifier_3d_2_screen_entered() -> void:
	self.show()


func _on_visible_on_screen_notifier_3d_2_screen_exited() -> void:
	self.hide()
