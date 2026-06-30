extends Area3D

@export var question_data: QuestionData
@export var porte_groupe: Node3D  # référence au groupe des 3 portes associées

signal question_declenchee(question: QuestionData, porte_groupe: Node3D)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("voiture"):
		print("indy enterd area")
		print(body.name)
		question_declenchee.emit(question_data, porte_groupe)
		queue_free()  # pour ne pas redéclencher
