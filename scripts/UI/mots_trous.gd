extends CanvasLayer

# Enum pour définir les niveaux de difficulté.
# Ils apparaîtront dans un menu déroulant dans l'inspecteur.
enum Difficulty {
	FACILE,    # 1 lettre manquante
	MOYEN,     # 2 lettres manquantes
	DIFFICILE  # 3 lettres manquantes
}

# --- VARIABLES EXPORTÉES ---

@export var words: Array[String] = ["godot", "gemini", "aventure", "magique", "programmation"]
@export var difficulty_level: Difficulty = Difficulty.FACILE


# --- NOEUDS DE LA SCÈNE ---

@onready var word_label: Label = %wordLbl
@onready var letter_input: LineEdit = %LineEdit
@onready var guess_button: Button = %Button
@onready var feedback_label: Label = %messagelbl


# --- VARIABLES DE JEU ---

var current_word_index: int = 0
var current_word: String
# Pour le niveau FACILE, on garde en mémoire la lettre. Pour les autres, le mot entier.
var solution: String


# --- FONCTIONS GODOT ---

func _ready() -> void:
	feedback_label.visible = false
	# Empêche le bouton de "voler" le focus après un clic
	guess_button.focus_mode = Control.FOCUS_NONE
	guess_button.pressed.connect(check_player_guess)
	letter_input.text_submitted.connect(check_player_guess)
	setup_new_word()


# Prépare un nouveau mot à deviner
func setup_new_word() -> void:
	if current_word_index >= words.size():
		word_label.text = "Jeu terminé !"
		letter_input.visible = false
		guess_button.visible = false
		feedback_label.text = "Bravo !"
		feedback_label.visible = true
		return

	current_word = words[current_word_index].to_lower()
	
	if current_word.is_empty():
		current_word_index += 1
		setup_new_word()
		return
	
	var letters_to_remove: int
	match difficulty_level:
		Difficulty.FACILE:
			letters_to_remove = 1
			letter_input.placeholder_text = "Entrez la lettre manquante"
		Difficulty.MOYEN:
			letters_to_remove = 2
			letter_input.placeholder_text = "Entrez le mot complet"
		Difficulty.DIFFICILE:
			letters_to_remove = 3
			letter_input.placeholder_text = "Entrez le mot complet"

	letters_to_remove = min(letters_to_remove, current_word.length())

	var indices_to_remove: Array[int] = []
	var i = 0
	while i < letters_to_remove:
		var random_index = randi() % current_word.length()
		if not random_index in indices_to_remove:
			indices_to_remove.append(random_index)
			i += 1
	
	if difficulty_level == Difficulty.FACILE:
		solution = current_word[indices_to_remove[0]]
	else:
		solution = current_word

	var displayed_word = ""
	for letter_index in range(current_word.length()):
		if letter_index in indices_to_remove:
			displayed_word += "_"
		else:
			displayed_word += current_word[letter_index]
			
	word_label.text = displayed_word
	feedback_label.visible = false
	letter_input.clear()
	force_focus_on_input()


func check_player_guess(_text: String = "") -> void:
	var player_guess = letter_input.text.to_lower()
	
	if player_guess.is_empty():
		return
	
	var is_correct: bool = false
	if difficulty_level == Difficulty.FACILE:
		is_correct = (player_guess == solution)
	else:
		is_correct = (player_guess == solution)

	if is_correct:
		feedback_label.text = "Correct ! Le mot était bien \"" + current_word + "\""
		feedback_label.visible = true
		current_word_index += 1
		
		letter_input.editable = false
		guess_button.disabled = true
		
		await get_tree().create_timer(2.0).timeout
		
		letter_input.editable = true
		guess_button.disabled = false
		setup_new_word()
	else:
		feedback_label.text = "Incorrect. Essayez encore !"
		feedback_label.visible = true
		letter_input.clear()
		force_focus_on_input()

# Attend un très court instant avant de forcer le focus, pour être sûr
# que cette commande est la dernière à être exécutée.
func force_focus_on_input() -> void:
	await get_tree().create_timer(0.05).timeout
	letter_input.grab_focus()
