extends Node

func _ready():
	# Appeler la fonction pour modifier la visibility_range de tous les MeshInstance3D
	set_visibility_range_for_all_meshes(self, 0.0, 80.0, 5.0, 5.0)
	set_lod_bias_for_all_meshes(self, 0.1) # Valeur entre 0.0 (basse qualité) et 1.0 (haute qualité)
	
func set_visibility_range_for_all_meshes(node: Node, begin: float, end: float, begin_margin: float, end_margin: float):
	# Vérifier si le nœud est un MeshInstance3D
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		# Modifier les paramètres de visibility_range
		mesh_instance.visibility_range_begin = begin
		mesh_instance.visibility_range_end = end
		mesh_instance.visibility_range_begin_margin = begin_margin
		mesh_instance.visibility_range_end_margin = end_margin
		# Activer l'utilisation de la visibility_range si nécessaire
		mesh_instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF # Ajustez selon vos besoins
		
	# Parcourir tous les enfants du nœud
	for child in node.get_children():
		set_visibility_range_for_all_meshes(child, begin, end, begin_margin, end_margin)


func set_lod_bias_for_all_meshes(node: Node, lod_bias: float):
	# Vérifier si le nœud est un MeshInstance3D
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		# Modifier le lod_bias
		mesh_instance.lod_bias = lod_bias
	
	# Parcourir tous les enfants
	for child in node.get_children():
		set_lod_bias_for_all_meshes(child, lod_bias)
