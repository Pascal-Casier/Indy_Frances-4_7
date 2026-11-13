extends Control

## Liste d'exercices : le joueur devra tous les compléter.
@export var exercices: Array[Exercice] = []
## Texte utilisé si la liste ci-dessus est vide.
@export_multiline var texte_par_defaut: String = "Le [chat|chien|poisson] [dort|vole|chante] sur le [canapé|nuage|arbre]."
## Si activé, l'ordre des exercices est mélangé à chaque série.
@export var melanger_ordre: bool = false
@export var couleur_correct: Color = Color.LIME_GREEN
@export var couleur_erreur: Color = Color.RED

@onready var progression: Label = %Progression
@onready var flux: HFlowContainer = %Texte
@onready var bouton: Button = %Valider
@onready var resultat: Label = %Resultat
@onready var bouton_suivant: Button = %Suivant
@onready var bouton_rejouer: Button = %Rejouer

var textes: Array[String] = []
var index_actuel: int = 0
var score_total: int = 0
var trous_total: int = 0
# Chaque trou : { "menu": OptionButton, "bonne": String }
var trous: Array = []


func _ready() -> void:
	bouton.pressed.connect(_on_valider)
	bouton_suivant.pressed.connect(_on_suivant)
	bouton_rejouer.pressed.connect(_demarrer_serie)
	_demarrer_serie()


func _demarrer_serie() -> void:
	textes.clear()
	var liste: Array = exercices.duplicate()
	if melanger_ordre:
		liste.shuffle()
	for ex in liste:
		if ex != null:
			textes.append(ex.texte)
	if textes.is_empty():
		textes.append(texte_par_defaut)

	index_actuel = 0
	score_total = 0
	trous_total = 0
	_afficher_exercice()


func _afficher_exercice() -> void:
	progression.text = "Exercice %d / %d" % [index_actuel + 1, textes.size()]
	construire_texte(textes[index_actuel])


func construire_texte(texte: String) -> void:
	for enfant in flux.get_children():
		enfant.queue_free()
	trous.clear()
	resultat.text = ""
	bouton.disabled = false
	bouton_suivant.visible = false
	bouton_rejouer.visible = false

	var regex := RegEx.new()
	regex.compile("\\[([^\\]]+)\\]")

	var position := 0
	for m in regex.search_all(texte):
		_ajouter_mots(texte.substr(position, m.get_start() - position))
		_ajouter_trou(m.get_string(1).split("|"))
		position = m.get_end()
	_ajouter_mots(texte.substr(position))


func _ajouter_mots(morceau: String) -> void:
	for mot in morceau.split(" ", false):
		var label := Label.new()
		label.text = mot
		flux.add_child(label)


func _ajouter_trou(options: PackedStringArray) -> void:
	var bonne := options[0]
	var melangees := Array(options)
	melangees.shuffle()

	var menu := OptionButton.new()
	menu.add_item("…")
	for opt in melangees:
		menu.add_item(opt)
	menu.fit_to_longest_item = true
	flux.add_child(menu)

	trous.append({"menu": menu, "bonne": bonne})


func _on_valider() -> void:
	var score := 0
	for trou in trous:
		var menu: OptionButton = trou["menu"]
		var choix := menu.get_item_text(menu.selected)
		var juste: bool = (menu.selected > 0 and choix == trou["bonne"])

		var couleur := couleur_correct if juste else couleur_erreur
		if juste:
			score += 1
		else:
			menu.tooltip_text = "Bonne réponse : " + trou["bonne"]
		menu.add_theme_color_override("font_color", couleur)
		menu.add_theme_color_override("font_disabled_color", couleur)
		menu.disabled = true

	score_total += score
	trous_total += trous.size()
	bouton.disabled = true
	resultat.text = "Score de l'exercice : %d / %d" % [score, trous.size()]

	if index_actuel < textes.size() - 1:
		bouton_suivant.visible = true
	else:
		_afficher_bilan_final()


func _afficher_bilan_final() -> void:
	var note := roundi(20.0 * score_total / max(trous_total, 1))
	resultat.text += "\n\nSérie terminée !\nScore total : %d / %d  (%d/20)" % [score_total, trous_total, note]
	bouton_rejouer.visible = true


func _on_suivant() -> void:
	index_actuel += 1
	_afficher_exercice()
