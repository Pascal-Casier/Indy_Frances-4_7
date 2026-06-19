class_name StateMachine
extends Node

# État actuel
var current_state: PlayerState
var states: Dictionary = {}

func _ready():
	# Attendre que tous les enfants soient prêts
	await owner.ready
	
	# Initialiser tous les états enfants
	for child in get_children():
		if child is PlayerState:
			states[child.name] = child
			child.player = owner
			child.animation_tree = owner.animation_tree
	
	# Démarrer avec le premier état
	if states.size() > 0:
		current_state = states.values()[0]
		current_state.enter()

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		var new_state_name = current_state.physics_update(delta)
		if new_state_name and new_state_name != "":
			transition_to(new_state_name)

func _input(event):
	if current_state:
		var new_state_name = current_state.handle_input(event)
		if new_state_name and new_state_name != "":
			transition_to(new_state_name)

func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		print("État non trouvé: ", state_name)
		return
	
	if current_state:
		current_state.exit()
	
	current_state = states[state_name]
	current_state.enter()
	print("Transition vers: ", state_name)
