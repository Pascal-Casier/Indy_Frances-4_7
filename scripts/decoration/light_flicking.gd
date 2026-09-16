extends OmniLight3D  # Ou SpotLight3D selon votre type de lumière

@export var door_num : int = -1
@export var kill_itself : bool = false
@export_group("Flicker Settings")
@export var min_energy: float = 0.2     # Énergie minimale
@export var max_energy: float = 1.5     # Énergie maximale
@export var flicker_speed: float = 0.05 # Intervalle entre deux variations (en secondes)

var timer: float = 0.0
var is_lit : bool = true

func _ready() -> void:
	Global.open_door_gate.connect(_on_open_door_received)
	
func _process(delta: float) -> void:
	timer += delta
	if timer >= flicker_speed:
		timer = 0.0
		# Génère une énergie aléatoire entre la valeur min et max
		light_energy = randf_range(min_energy, max_energy)

func _on_open_door_received(_door_nbr):
	if door_num == _door_nbr:
		if kill_itself:
			queue_free()
			return
		if is_lit:
			hide()
			is_lit = false
		elif not is_lit:
			show()
			is_lit = true
	
