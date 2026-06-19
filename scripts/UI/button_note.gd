extends Button
class_name NoteButton

var note_title : String = "title"
var note_content : String = "content"

func _ready() -> void:
	text = note_title
