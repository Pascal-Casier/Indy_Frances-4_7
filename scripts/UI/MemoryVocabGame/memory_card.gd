extends Button


# Définissez les propriétés de la carte
@export var word: String = ""
@export var match: String = ""

func _ready():
	# S'assurer que le label prend le texte du bouton
	$Label.text = self.text
	
# Si vous voulez une interaction plus complexe, vous pouvez émettre un signal
# pour informer le script principal que la carte a été cliquée, mais ici
# nous connectons directement le signal du bouton dans le script principal.
