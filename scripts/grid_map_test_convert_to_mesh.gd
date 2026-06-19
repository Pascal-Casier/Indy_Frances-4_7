extends GridMap

func bake_to_mesh():
	var meshes = make_baked_meshes()
	
	for mesh_data in meshes:
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = mesh_data
		get_parent().add_child(mesh_instance)
		mesh_instance.owner = get_tree().edited_scene_root
	
	# Optionnel : désactiver la GridMap après
	visible = false
