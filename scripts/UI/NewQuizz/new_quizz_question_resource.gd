# question_resource.gd
extends Resource
class_name QuestionResource

@export var question_text: String = ""
@export var audio_stream: AudioStream 
@export var correct_answer: String = ""
@export var wrong_answers: Array[String] = []

func get_all_answers() -> Array[String]:
	var answers = wrong_answers.duplicate()
	answers.append(correct_answer)
	answers.shuffle()
	return answers
