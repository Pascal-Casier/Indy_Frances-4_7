extends Control

@onready var note_container: GridContainer = %NoteContainer
@onready var feuille_note: NinePatchRect = %Feuille_note
var mouse_visible : bool = false

func _ready() -> void:
	Global.new_note.connect(load_notes)
	Global.add_note("être", "je suis, tu es, il est")
	load_notes()

func load_notes():
	for child in note_container.get_children():
		child.queue_free()
	for note in Global.notes:
		var bouton = NoteButton.new()
		bouton.note_title = note["title"]
		bouton.pressed.connect(_on_note_pressed.bind(note))
		note_container.add_child(bouton)
	

func _on_note_pressed(note):
	%Label.text = note["content"]
	feuille_note.show()
	

func _on_button_exit_pressed() -> void:
	feuille_note.hide()
