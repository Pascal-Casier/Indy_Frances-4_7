@tool
extends Node3D

## Script pour générer automatiquement des collisions convexes pour tous les MeshInstance3D enfants
## Attachez ce script au noeud parent contenant vos meshes et cliquez sur "Apply Collisions"

@export_group("Collision Settings")
@export var simplify_collision: bool = true ## Simplifier la forme de collision
@export var clean_existing: bool = false ## Supprimer les collisions existantes avant de regénérer
@export_range(0.0, 1.0, 0.01) var simplification_factor: float = 0.5 ## Facteur de simplification (0 = max simplifié, 1 = détaillé)

@export_group("Actions")
@export var apply_collisions: bool = false: ## Cliquez pour générer les collisions
	set(value):
		if value and Engine.is_editor_hint():
			generate_collisions()
		apply_collisions = false

@export var remove_all_collisions: bool = false: ## Supprimer toutes les collisions générées
	set(value):
		if value and Engine.is_editor_hint():
			clear_all_collisions()
		remove_all_collisions = false


func generate_collisions() -> void:
	"""Génère des collisions pour tous les MeshInstance3D enfants"""
	
	if clean_existing:
		clear_all_collisions()
	
	var mesh_nodes = get_all_mesh_instances(self)
	var count = 0
	
	for mesh_instance in mesh_nodes:
		if create_collision_for_mesh(mesh_instance):
			count += 1
	
	# Force la mise à jour de l'éditeur
	notify_property_list_changed()
	print("✓ Collisions générées pour %d mesh(es)" % count)


func get_all_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	"""Récupère récursivement tous les MeshInstance3D"""
	var meshes: Array[MeshInstance3D] = []
	
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
		
		# Recherche récursive dans les enfants
		meshes.append_array(get_all_mesh_instances(child))
	
	return meshes


func create_collision_for_mesh(mesh_instance: MeshInstance3D) -> bool:
	"""Crée un StaticBody3D avec CollisionShape3D pour un mesh donné"""
	
	if not mesh_instance.mesh:
		push_warning("Le mesh '%s' n'a pas de ressource mesh assignée" % mesh_instance.name)
		return false
	
	# Vérifier si une collision existe déjà
	var existing_body = mesh_instance.find_child("CollisionBody", false, false)
	if existing_body:
		if not clean_existing:
			print("⊘ Collision déjà existante pour '%s' (activez 'clean_existing' pour régénérer)" % mesh_instance.name)
			return false
		else:
			existing_body.queue_free()
	
	# Générer la forme convexe
	var shape = generate_convex_shape(mesh_instance.mesh)
	if not shape:
		push_warning("Impossible de générer une forme de collision pour '%s'" % mesh_instance.name)
		return false
	
	# Créer le StaticBody3D
	var static_body = StaticBody3D.new()
	static_body.name = "CollisionBody"
	
	# Créer le CollisionShape3D
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape"
	collision_shape.shape = shape
	
	# Construire la hiérarchie
	mesh_instance.add_child(static_body)
	static_body.add_child(collision_shape)
	
	# Définir le owner pour l'éditeur (très important!)
	var root = get_tree().edited_scene_root
	if root:
		static_body.owner = root
		collision_shape.owner = root
	
	print("✓ Collision créée pour '%s'" % mesh_instance.name)
	return true


func generate_convex_shape(mesh: Mesh) -> ConvexPolygonShape3D:
	"""Génère une forme convexe à partir d'un mesh"""
	
	var shape = ConvexPolygonShape3D.new()
	var points: PackedVector3Array = []
	
	# Extraire tous les vertices du mesh
	for surface_idx in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface_idx)
		if arrays and arrays[Mesh.ARRAY_VERTEX]:
			var vertices = arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
			points.append_array(vertices)
	
	if points.is_empty():
		return null
	
	# Simplification si activée
	if simplify_collision and simplification_factor < 1.0:
		points = simplify_point_cloud(points, simplification_factor)
	
	shape.points = points
	return shape


func simplify_point_cloud(points: PackedVector3Array, factor: float) -> PackedVector3Array:
	"""Simplifie un nuage de points en réduisant le nombre de vertices"""
	
	if factor >= 1.0:
		return points
	
	var target_count = max(4, int(points.size() * factor))  # Minimum 4 points pour une forme 3D
	var simplified: PackedVector3Array = []
	var step = max(1, int(points.size() / float(target_count)))
	
	for i in range(0, points.size(), step):
		simplified.append(points[i])
		if simplified.size() >= target_count:
			break
	
	return simplified


func clear_all_collisions() -> void:
	"""Supprime toutes les collisions générées"""
	
	var mesh_nodes = get_all_mesh_instances(self)
	var count = 0
	
	for mesh_instance in mesh_nodes:
		# Chercher tous les enfants StaticBody3D
		for child in mesh_instance.get_children():
			if child is StaticBody3D:
				print("Suppression de collision pour '%s'" % mesh_instance.name)
				child.queue_free()
				count += 1
	
	# Force la mise à jour
	notify_property_list_changed()
	print("✗ %d collision(s) supprimée(s)" % count)
