extends Node3D

@onready var room_scene: Node3D = $RoomSceneInfinite
@onready var room_scene2: Node3D = $RoomSceneInfinite2
@onready var end_position_marker: Marker3D = $EndPositionMarker

var speed := 5.0
var distanceBetweenRooms : float

func _ready() -> void:
	distanceBetweenRooms = abs(room_scene.global_position.z - room_scene2.global_position.z)
	
func _process(delta: float) -> void:
	room_scene.global_position.z -= speed * delta
	room_scene2.global_position.z -= speed * delta
	
	var room1ReachedEnd = room_scene.global_position.z <= end_position_marker.global_position.z
	var room2ReachedEnd = room_scene2.global_position.z <= end_position_marker.global_position.z
	
	if room1ReachedEnd:
		room_scene.global_position.z = room_scene2.global_position.z + distanceBetweenRooms
	
	if room2ReachedEnd:
		room_scene2.global_position.z = room_scene.global_position.z + distanceBetweenRooms
		
