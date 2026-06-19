extends StaticBody3D

@export var blow_force : int = 2
@onready var destruction: Destruction = $Destruction
@onready var cracks: Node3D = $cracks
@onready var cracks_2: Node3D = $cracks2

signal play_sound
var index := 0

func destroy(force = blow_force):
	match index :
		0 :
			cracks.show()
			index +=1
		1 :
			cracks_2.show()
			index +=1
		2 :
			destruction.destroy(force)
			play_sound.emit()
		_ :
			return
	
func hit(_damage):
	pass
	
