extends Area3D

@export var nomFr : String
@export var nomBR : String
@export var categorie : String

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_on_note_collected()

func _on_note_collected():
	Global.emit_signal("note_collected", 
		{nomFr: nomBR}, 
		categorie
	)
	queue_free()
