extends Node3D

enum MovementType {
	VERTICAL,
	LATERAL,
	ROTATION_Y
}

enum LateralAxis {
	X,
	Z
}

@export var door_number : int = -1
@export var target_node : Node3D
@export var move_time: float = 1.0
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

@export_category("Paramètres de Mouvement")
# On utilise un setter (set) pour notifier Godot de rafraîchir l'inspecteur dès qu'on change le type
@export var movement_type : MovementType = MovementType.VERTICAL:
	set(value):
		movement_type = value
		notify_property_list_changed() # Demande à Godot de mettre à jour l'affichage de l'inspecteur

@export var move_distance: float = 3.0 ## Distance du déplacement (en mètres) pour Vertical ou Latéral
@export var lateral_axis: LateralAxis = LateralAxis.X ## Axe pour le déplacement latéral (X ou Z)
@export var rotation_amount: float = 90.0 ## Angle de rotation sur l'axe Y (en degrés)

var initial_position: Vector3
var initial_rotation: Vector3
var is_moving: bool = false

# Cette fonction permet de filtrer dynamiquement ce qui s'affiche dans l'inspecteur
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	# On cache/montre les propriétés en fonction de la valeur de movement_type
	if movement_type == MovementType.ROTATION_Y:
		# Si c'est une rotation, on cache move_distance et lateral_axis
		properties.append({
			"name": "rotation_amount",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	else:
		# Si c'est Vertical ou Latéral, on affiche move_distance
		properties.append({
			"name": "move_distance",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT
		})
		# Si c'est spécifiquement Latéral, on rajoute le choix de l'axe (X ou Z)
		if movement_type == MovementType.LATERAL:
			properties.append({
				"name": "lateral_axis",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "X,Z" # Crée le menu déroulant pour l'enum LateralAxis
			})
			
	return properties

func _ready() -> void:
	if target_node:
		initial_position = target_node.position
		initial_rotation = target_node.rotation_degrees
	
	Global.open_door_gate.connect(open_door)
	
func open_door(nbr: int) -> void:
	if is_moving or door_number != nbr or not target_node:
		return
	is_moving = true
	
	if audio_player and audio_player.stream:
		audio_player.play()
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	match movement_type:
		MovementType.VERTICAL:
			tween.tween_property(target_node, "position:y", initial_position.y + move_distance, move_time)
			
		MovementType.LATERAL:
			if lateral_axis == LateralAxis.X:
				tween.tween_property(target_node, "position:x", initial_position.x + move_distance, move_time)
			else:
				tween.tween_property(target_node, "position:z", initial_position.z + move_distance, move_time)
				
		MovementType.ROTATION_Y:
			tween.tween_property(target_node, "rotation_degrees:y", initial_rotation.y + rotation_amount, move_time)
	
	await tween.finished
	
	if audio_player:
		audio_player.stop()
	is_moving = false
