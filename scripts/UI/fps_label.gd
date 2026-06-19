extends Control


func _ready() -> void:
	Global.words_found_number.connect(update_word_nb)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())

func update_word_nb(nbr : int):
	$LabelMots.text = str(nbr) + " mots trouvé(s)"
