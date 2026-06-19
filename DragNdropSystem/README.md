# 🧩 Phrase Puzzle — Godot 4.4

Jeu de reconstitution de phrases par drag & drop.

## Structure des fichiers

```
project.godot     ← config du projet
Main.tscn         ← scène principale (à ouvrir dans Godot)
Main.gd           ← logique du jeu (phrases, vérification, navigation)
WordCard.gd       ← mot draggable (implémente _get_drag_data)
DropSlot.gd       ← zone de dépôt (implémente _can_drop_data / _drop_data)
```

## Comment ça marche

### Système drag & drop natif (Godot 4)

| Fichier       | Méthode             | Rôle |
|---------------|---------------------|------|
| `WordCard.gd` | `_get_drag_data()`  | Démarre le drag, retourne `self` comme donnée |
| `WordCard.gd` | `_make_preview()`   | Crée le visuel affiché pendant le drag |
| `DropSlot.gd` | `_can_drop_data()`  | Vérifie si le drop est accepté (+ hover visuel) |
| `DropSlot.gd` | `_drop_data()`      | Reçoit le mot et émet le signal `word_dropped` |
| `Main.gd`     | `_on_word_dropped_in_slot()` | Repositionne la carte, gère les échanges |

### Ajouter des phrases

Dans `Main.gd`, modifier le tableau `PHRASES` :

```gdscript
const PHRASES = [
	{
		"tokens": ["Le", "TROU", "mange", "une", "TROU"],
		"answers": ["chat", "souris"],       # dans l'ordre des TROU
		"distractors": ["chien", "pomme"]    # mots pièges
	},
	# ...
]
```

- `"TROU"` dans `tokens` → crée un `DropSlot`
- `"answers"` → les bonnes réponses, dans le même ordre que les TROU
- `"distractors"` → mots supplémentaires pour tromper

## Fonctionnalités

- ✅ Drag & drop natif Godot 4 (`_get_drag_data` / `_can_drop_data` / `_drop_data`)
- ✅ Échange de mots entre slots
- ✅ Retour au word bank si slot occupé
- ✅ Feedback visuel (vert = correct, rouge = incorrect, orange = vide)
- ✅ Plusieurs phrases avec navigation
- ✅ Bouton reset

## Installation

1. Ouvre Godot 4.4
2. "Import" → sélectionner `project.godot`
3. Lance le projet (F5)
