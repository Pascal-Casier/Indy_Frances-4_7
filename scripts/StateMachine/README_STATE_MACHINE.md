# Guide d'Utilisation de la State Machine pour Indiana Jones

## 📁 Structure des Fichiers

Voici les fichiers créés pour la state machine :

1. **player_state.gd** - Classe de base pour tous les états
2. **state_machine.gd** - Le contrôleur de la state machine
3. **state_idle.gd** - État repos/inactif
4. **state_movement.gd** - État marche/course
5. **state_jump.gd** - État saut
6. **state_fall.gd** - État chute
7. **state_aim.gd** - État visée
8. **state_attack.gd** - État attaque
9. **state_grapple.gd** - État grappin
10. **state_death.gd** - État mort
11. **player_with_state_machine.gd** - Script principal du joueur modifié

## 🎯 Configuration dans Godot

### Étape 1 : Préparer la hiérarchie de nœuds

Dans votre scène de joueur, ajoutez un nœud de type `Node` comme enfant du joueur :

```
CharacterBody3D (Player)
├── StateMachine (Node)
│   ├── Idle (Node)
│   ├── Movement (Node)
│   ├── Jump (Node)
│   ├── Fall (Node)
│   ├── Aim (Node)
│   ├── Attack (Node)
│   ├── Grapple (Node)
│   └── Death (Node)
├── IndianaJones_Model_4_2
├── camroot
└── ... (autres nœuds existants)
```

### Étape 2 : Assigner les scripts

1. **Au nœud Player (CharacterBody3D)** :
   - Remplacez le script actuel par `player_with_state_machine.gd`

2. **Au nœud StateMachine** :
   - Assignez le script `state_machine.gd`

3. **Aux nœuds enfants de StateMachine** :
   - Idle → `state_idle.gd`
   - Movement → `state_movement.gd`
   - Jump → `state_jump.gd`
   - Fall → `state_fall.gd`
   - Aim → `state_aim.gd`
   - Attack → `state_attack.gd`
   - Grapple → `state_grapple.gd`
   - Death → `state_death.gd`

⚠️ **Important** : Les noms des nœuds doivent correspondre exactement aux noms ci-dessus car la state machine les utilise pour les transitions !

## 🔄 Comment Fonctionne la State Machine

### Principe de Base

Chaque état hérite de `PlayerState` et implémente trois méthodes principales :

- **enter()** : Appelé quand on entre dans l'état
- **physics_update(delta)** : Appelé chaque frame physique, retourne le nom du prochain état
- **exit()** : Appelé quand on sort de l'état

### Exemple de Transition

```gdscript
# Dans state_idle.gd
func physics_update(delta: float) -> String:
    # Si le joueur appuie sur une touche de mouvement
    if Input.is_action_pressed("forward"):
        return "Movement"  # Transition vers l'état Movement
    
    return ""  # Rester dans Idle
```

### Diagramme des États

```
┌─────────┐
│  Idle   │◄────────┬───────────┐
└────┬────┘         │           │
     │              │           │
     ▼              │           │
┌─────────┐         │           │
│Movement │─────────┘           │
└────┬────┘                     │
     │                          │
     ▼                          │
┌─────────┐                     │
│  Jump   │                     │
└────┬────┘                     │
     │                          │
     ▼                          │
┌─────────┐                     │
│  Fall   │─────────────────────┘
└────┬────┘         ▲
     │              │
     ├──────────────┘
     │
     ▼
┌─────────┐         ┌─────────┐
│  Aim    │────────►│ Attack  │
└─────────┘         └─────────┘

      Grapple (peut être activé depuis n'importe quel état)
      Death (activé quand health <= 0)
```

## 🎮 Avantages de la State Machine

### ✅ Code Plus Clair
- Chaque état est isolé dans son propre fichier
- Plus facile à lire et comprendre
- Logique séparée par comportement

### ✅ Maintenance Simplifiée
- Modifier un état n'affecte pas les autres
- Ajouter de nouveaux états est facile
- Déboguer devient simple (on sait exactement dans quel état on est)

### ✅ Évite les Bugs
- Moins de conditions imbriquées complexes
- Transitions explicites entre états
- Impossible d'être dans deux états à la fois

## 🆕 Ajouter un Nouvel État

Si vous voulez ajouter un nouvel état (par exemple "Climb" pour grimper) :

1. Créez un nouveau fichier `state_climb.gd` :

```gdscript
extends PlayerState

func enter() -> void:
    print("Entrée dans Climb")
    # Votre logique d'entrée

func physics_update(delta: float) -> String:
    # Votre logique de mise à jour
    
    # Conditions de sortie
    if not Input.is_action_pressed("climb"):
        return "Idle"
    
    return ""

func exit() -> void:
    # Nettoyage si nécessaire
    pass
```

2. Ajoutez un nœud "Climb" sous StateMachine dans la scène
3. Assignez-lui le script `state_climb.gd`
4. Ajoutez les transitions depuis d'autres états :

```gdscript
# Dans state_idle.gd ou state_movement.gd
func physics_update(delta: float) -> String:
    # ... autres conditions ...
    
    if Input.is_action_pressed("climb"):
        return "Climb"
    
    return ""
```

## 🐛 Débogage

Pour voir les transitions d'états en temps réel, regardez la console Godot. Chaque état affiche "Entrée dans [NomÉtat]" quand il est activé.

Vous pouvez aussi ajouter plus de prints dans la méthode `transition_to()` de `state_machine.gd`.

## 📊 Différences avec l'Ancien Code

### Avant (Monolithique)
```gdscript
func _physics_process(delta):
    if grappling:
        # logique grappin
    elif jumping:
        # logique saut
    elif aiming:
        # logique visée
    elif moving:
        # logique mouvement
    else:
        # logique idle
    # ... 500 lignes de code imbriqué
```

### Après (State Machine)
```gdscript
# Dans la state machine
func _physics_process(delta):
    var new_state = current_state.physics_update(delta)
    if new_state:
        transition_to(new_state)

# Chaque état = ~50 lignes maximum, bien organisées
```

## 🎓 Concepts Avancés

### États Imbriqués
Vous pouvez créer des sous-états en ajoutant une state machine dans un état. Par exemple, "Movement" pourrait avoir ses propres sous-états "Walk" et "Run".

### États Parallèles
Si vous avez besoin que plusieurs comportements fonctionnent en même temps (par exemple, mouvement + santé), vous pouvez créer plusieurs state machines.

### Animation State Machine
Votre AnimationTree a déjà sa propre state machine. La state machine de code contrôle quelle animation state machine utiliser.

## 📝 Notes Importantes

1. **Ordre des États** : L'ordre des vérifications dans `physics_update()` est important. Vérifiez toujours les états prioritaires en premier (comme Death ou Grapple).

2. **Références au Player** : Tous les états ont accès au joueur via `player` et à l'animation tree via `animation_tree`.

3. **Move and Slide** : Le `move_and_slide()` est toujours appelé dans le `_physics_process` du joueur, les états ne font que modifier `velocity`.

4. **Async/Await** : Faites attention avec `await` dans les états. Utilisez des flags (comme `is_attacking`) pour gérer les animations longues.

## 🚀 Prochaines Étapes

Une fois que vous êtes à l'aise avec ce système, vous pouvez :
- Ajouter plus d'états (escalade, nage, etc.)
- Créer des sous-state machines pour des comportements complexes
- Implémenter un système de state stack pour revenir à l'état précédent
- Ajouter des transitions avec cooldown ou conditions complexes

Bon développement ! 🎮
