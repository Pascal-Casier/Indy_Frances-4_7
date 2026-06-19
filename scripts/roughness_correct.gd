extends Node3D

func _ready():
	fix_roughness(self)

func fix_roughness(node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var mat = node.get_active_material(i)
				if mat and mat is StandardMaterial3D:
					mat.roughness = 1.0

	for child in node.get_children():
		fix_roughness(child)
