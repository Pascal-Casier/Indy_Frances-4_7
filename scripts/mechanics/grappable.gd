extends StaticBody3D

@onready var pos: Marker3D = $landing_pos
@onready var contour: MeshInstance3D = $MeshInstance3D/contour

func contour_enable():
	if !contour.visible:
		contour.show()
	else:
		contour.hide()
