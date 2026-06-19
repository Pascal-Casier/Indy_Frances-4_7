extends Control

signal success
# Listes configurables dans l'éditeur - les indices correspondent aux mots par index
@export var mots: Array[String] = ["GODOT", "PROGRAMMATION", "PENDU", "VICTOIRE"]
@export_multiline var indices: Array[String] = [
	"Moteur de jeu open-source",
	"Action d'écrire du code",
	"Jeu de lettres classique",
	"Succès dans une compétition"
]
@export var max_erreurs: int = 7
@export var cout_indice: int = 1  # Nombre d'erreurs ajoutées pour utiliser un indice
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

const CORRECT = preload("res://assets/sounds/sfx/correct_sound.mp3")
const INCORRECT = preload("res://assets/sounds/sfx/incorrect_sound.mp3")
# Variables du jeu
var mot_secret: String = ""
var indice_actuel: String = ""
var mot_affiche: Array = []
var lettres_trouvees: Array = []
var erreurs: int = 0
var partie_terminee: bool = false
var indice_utilise: bool = false

# Variables pour le parcours de tous les mots
var mots_restants: Array = []  # Indices des mots pas encore joués
var mots_reussis: int = 0  # Nombre de mots trouvés
var tous_mots_termines: bool = false

# Références aux nœuds
@onready var label_mot = %MotLabel
@onready var label_erreurs = %ErreursLabel
@onready var label_status = %StatusLabel
@onready var label_indice = %IndiceLabel  # Nouveau label pour l'indice
@onready var bouton_nouvelle_partie = %NouvellePartieButton
@onready var bouton_indice = %IndiceButton  # Nouveau bouton pour demander un indice
@onready var conteneur_lettres = %LettresContainer
@onready var button_exit: Button = %ButtonExit


func _ready():
	randomize()
	creer_boutons_lettres()
	# Connecter le bouton d'indice s'il existe
	if bouton_indice:
		bouton_indice.pressed.connect(_on_indice_button_pressed)
	initialiser_liste_mots()
	nouvelle_partie()

func initialiser_liste_mots():
	# Créer une liste mélangée de tous les indices de mots
	mots_restants.clear()
	for i in range(mots.size()):
		mots_restants.append(i)
	mots_restants.shuffle()
	mots_reussis = 0
	tous_mots_termines = false

func creer_boutons_lettres():
	# Créer un bouton pour chaque lettre de l'alphabet
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var ligne_actuelle = HBoxContainer.new()
	conteneur_lettres.add_child(ligne_actuelle)
	
	for i in range(alphabet.length()):
		if i > 0 and i % 9 == 0:
			ligne_actuelle = HBoxContainer.new()
			conteneur_lettres.add_child(ligne_actuelle)
		
		var btn = Button.new()
		btn.text = alphabet[i]
		btn.custom_minimum_size = Vector2(50, 50)
		btn.pressed.connect(_on_lettre_pressee.bind(alphabet[i]))
		ligne_actuelle.add_child(btn)

func nouvelle_partie():
	button_exit.hide()
	if mots.is_empty():
		label_status.text = "Erreur: Aucun mot configuré!"
		return
	
	# Vérifier que les tableaux ont la même taille
	if mots.size() != indices.size():
		push_warning("Le nombre de mots et d'indices ne correspond pas!")
	
	# Vérifier s'il reste des mots à jouer
	if mots_restants.is_empty():
		tous_mots_termines = true
		afficher_fin_jeu()
		return
	
	# Prendre le prochain mot de la liste
	var index = mots_restants.pop_front()
	mot_secret = mots[index].to_upper()
	indice_actuel = indices[index] if index < indices.size() else "Pas d'indice disponible"
	
	# Réinitialiser les variables
	mot_affiche.clear()
	lettres_trouvees.clear()
	erreurs = 0
	partie_terminee = false
	indice_utilise = false
	
	# Préparer l'affichage du mot
	for i in range(mot_secret.length()):
		mot_affiche.append("_")
	
	# Réactiver tous les boutons
	reactiver_boutons()
	
	# Mettre à jour l'affichage
	mettre_a_jour_affichage()
	label_status.text = "Mot %d/%d - Bonne chance!" % [mots_reussis + 1, mots.size()]
	
	# Gérer l'affichage de l'indice
	if label_indice:
		label_indice.text = "💡 Indice disponible (coût: +%d erreur%s)" % [cout_indice, "s" if cout_indice > 1 else ""]
	
	if bouton_indice:
		bouton_indice.visible = true
		bouton_indice.disabled = false
	
	bouton_nouvelle_partie.visible = false

func _on_lettre_pressee(lettre: String):
	if partie_terminee:
		return
	
	# Désactiver le bouton cliqué
	desactiver_bouton_lettre(lettre)
	
	# Vérifier si la lettre est dans le mot
	if mot_secret.contains(lettre):
		lettres_trouvees.append(lettre)
		
		#son correct 
		audio_stream_player.stream = CORRECT
		audio_stream_player.play()
		
		# Révéler toutes les occurrences de cette lettre
		for i in range(mot_secret.length()):
			if mot_secret[i] == lettre:
				mot_affiche[i] = lettre
		
		# Vérifier la victoire
		if not mot_affiche.has("_"):
			victoire()
	else:
		erreurs += 1
		#son correct 
		audio_stream_player.stream = INCORRECT
		audio_stream_player.play()
		
		# Vérifier la défaite
		if erreurs >= max_erreurs:
			defaite()
	
	mettre_a_jour_affichage()

func _on_indice_button_pressed():
	if partie_terminee or indice_utilise:
		return
	
	# Afficher l'indice
	if label_indice:
		label_indice.text = "💡 Indice: " + indice_actuel
	
	# Ajouter le coût en erreurs
	erreurs += cout_indice
	indice_utilise = true
	
	# Désactiver le bouton d'indice
	if bouton_indice:
		bouton_indice.disabled = true
	
	# Vérifier la défaite après l'utilisation de l'indice
	if erreurs >= max_erreurs:
		defaite()
	
	mettre_a_jour_affichage()

func mettre_a_jour_affichage():
	# Afficher le mot avec des espaces entre les lettres
	label_mot.text = " ".join(mot_affiche)
	label_erreurs.text = "Erreurs: %d / %d" % [erreurs, max_erreurs]

func victoire():
	partie_terminee = true
	mots_reussis += 1
	
	# Vérifier s'il reste des mots
	if mots_restants.is_empty():
		label_status.text = "🎉 VICTOIRE! Le mot était: " + mot_secret + "\n🏆 Vous avez trouvé tous les mots!"
	else:
		label_status.text = "🎉 VICTOIRE! Le mot était: " + mot_secret + "\n(%d/%d mots trouvés)" % [mots_reussis, mots.size()]
	
	bouton_nouvelle_partie.visible = true
	if mots_restants.is_empty():
		bouton_nouvelle_partie.text = "Recommencer tous les mots"
		button_exit.show()
	else:
		bouton_nouvelle_partie.text = "Mot suivant"
	
	desactiver_tous_boutons()
	if bouton_indice:
		bouton_indice.visible = false

func defaite():
	partie_terminee = true
	label_status.text = "😞 PERDU! Le mot était: " + mot_secret + "\n(%d/%d mots trouvés)" % [mots_reussis, mots.size()]
	
	# Révéler le mot complet
	for i in range(mot_secret.length()):
		mot_affiche[i] = mot_secret[i]
	mettre_a_jour_affichage()
	
	bouton_nouvelle_partie.visible = true
	if mots_restants.is_empty():
		bouton_nouvelle_partie.text = "Recommencer tous les mots"
	else:
		bouton_nouvelle_partie.text = "Mot suivant"
	
	desactiver_tous_boutons()
	if bouton_indice:
		bouton_indice.visible = false

func desactiver_bouton_lettre(lettre: String):
	for ligne in conteneur_lettres.get_children():
		for btn in ligne.get_children():
			if btn is Button and btn.text == lettre:
				btn.disabled = true
				return

func desactiver_tous_boutons():
	for ligne in conteneur_lettres.get_children():
		for btn in ligne.get_children():
			if btn is Button:
				btn.disabled = true

func reactiver_boutons():
	for ligne in conteneur_lettres.get_children():
		for btn in ligne.get_children():
			if btn is Button:
				btn.disabled = false

func _on_nouvelle_partie_button_pressed():
	# Si tous les mots ont été joués, réinitialiser la liste
	if mots_restants.is_empty():
		initialiser_liste_mots()
	nouvelle_partie()

func afficher_fin_jeu():
	partie_terminee = true
	label_status.text = "🏆 FÉLICITATIONS! 🏆\nVous avez trouvé tous les %d mots de la liste!" % mots.size()
	bouton_nouvelle_partie.visible = true
	bouton_nouvelle_partie.text = "Recommencer tous les mots"
	desactiver_tous_boutons()
	if bouton_indice:
		bouton_indice.visible = false


func _on_button_exit_pressed() -> void:
	if partie_terminee:
		success.emit()
		hide()
		
