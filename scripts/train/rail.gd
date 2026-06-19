extends Node3D
class_name RailsGenerator

@export var path_to_follow: Path3D
@export var rail_mesh: Mesh  # Mesh importé depuis Blender
@export var rail_segment_length: float = 5.0  # Longueur d'un segment de rail
@export var use_multimesh: bool = true  # Optimisation avec MultiMesh

var rail_instances = []

func _ready():
	if path_to_follow and rail_mesh:
		generate_rails_from_mesh()
	elif not rail_mesh:
		push_warning("Aucun mesh de rail assigné ! Importez votre modèle Blender.")

func generate_rails_from_mesh():
	# Nettoyer les anciennes instances
	clear_rails()
	
	var curve = path_to_follow.curve
	if not curve:
		push_error("Aucune courbe trouvée dans le Path3D")
		return
	
	if use_multimesh:
		generate_with_multimesh(curve)
	else:
		generate_with_meshinstances(curve)

# Méthode 1 : MultiMesh (PERFORMANT - recommandé)
func generate_with_multimesh(curve: Curve3D):
	var curve_length = curve.get_baked_length()
	var segment_count = int(curve_length / rail_segment_length)
	
	var multimesh_instance = MultiMeshInstance3D.new()
	var multimesh = MultiMesh.new()
	
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = rail_mesh
	multimesh.instance_count = segment_count
	
	for i in range(segment_count):
		var distance = i * rail_segment_length
		var transform = curve.sample_baked_with_rotation(distance)
		
		# Ajuster l'orientation si nécessaire
		# Par défaut, le mesh suit la courbe
		# Si votre mesh Blender n'est pas orienté correctement, ajustez ici :
		#transform = transform.rotated(Vector3.UP, deg_to_rad(90))
		
		multimesh.set_instance_transform(i, transform)
	
	multimesh_instance.multimesh = multimesh
	add_child(multimesh_instance)
	rail_instances.append(multimesh_instance)
	
	print("Rails générés : ", segment_count, " segments avec MultiMesh")

# Méthode 2 : MeshInstance individuels (plus flexible mais moins performant)
func generate_with_meshinstances(curve: Curve3D):
	var curve_length = curve.get_baked_length()
	var segment_count = int(curve_length / rail_segment_length)
	
	for i in range(segment_count):
		var distance = i * rail_segment_length
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = rail_mesh
		
		# Positionner et orienter le segment
		var transform = curve.sample_baked_with_rotation(distance)
		mesh_instance.transform = transform
		
		add_child(mesh_instance)
		rail_instances.append(mesh_instance)
	
	print("Rails générés : ", segment_count, " segments individuels")

# Méthode 3 : PathFollow3D (pour animation ou mouvement dynamique)
func generate_with_pathfollow():
	var path_follow = PathFollow3D.new()
	path_to_follow.add_child(path_follow)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = rail_mesh
	path_follow.add_child(mesh_instance)
	
	# Pour animer le long du chemin :
	# path_follow.progress_ratio = 0.5  # 50% du chemin
	
	rail_instances.append(path_follow)

func clear_rails():
	for instance in rail_instances:
		instance.queue_free()
	rail_instances.clear()

func regenerate_rails():
	if path_to_follow and rail_mesh:
		generate_rails_from_mesh()
		print("Rails régénérés")



#extends MeshInstance3D
#class_name RailsGenerator
#
#@export var path_to_follow: Path3D
#@export var rail_width: float = 1.435  # Écartement standard européen en mètres
#@export var rail_height: float = 0.1   # Hauteur des rails
#@export var tie_spacing: float = 0.6   # Distance entre les traverses
#@export var tie_width: float = 2.5     # Largeur des traverses
#@export var tie_height: float = 0.2    # Épaisseur des traverses
#@export var steps: int = 200           # Nombre de points sur la courbe
#
#func _ready():
	#if path_to_follow:
		#generate_complete_rails()
#
#func generate_complete_rails():
	#var curve = path_to_follow.curve
	#if not curve:
		#print("Aucune courbe trouvée dans le Path3D")
		#return
	#
	## Créer un ArrayMesh pour combiner rails et traverses
	#var array_mesh = ArrayMesh.new()
	#
	## Générer les rails (2 lignes parallèles)
	#generate_rail_tracks(array_mesh, curve)
	#
	## Générer les traverses (perpendiculaires aux rails)
	#generate_rail_ties(array_mesh, curve)
	#
	## Appliquer le mesh final
	#mesh = array_mesh
	#
	## Appliquer un matériau
	#apply_rail_material()
#
## Génération des rails (2 lignes parallèles)
#func generate_rail_tracks(array_mesh: ArrayMesh, curve: Curve3D):
	#var vertices = PackedVector3Array()
	#var normals = PackedVector3Array()
	#var uvs = PackedVector2Array()
	#var indices = PackedInt32Array()
	#
	#print("Génération de ", steps + 1, " points pour les rails")
	#
	## Échantillonner des points le long de la courbe
	#for i in range(steps + 1):
		#var t = float(i) / float(steps)  # Progression de 0 à 1
		#var curve_length = curve.get_baked_length()
		#var distance = t * curve_length
		#
		## Obtenir position et orientation à ce point
		#var pos = curve.sample_baked(distance)
		#var transform = curve.sample_baked_with_rotation(distance)
		#
		## Calculer les directions
		#var forward = -transform.basis.z.normalized()  # Direction du train
		#var right = transform.basis.x.normalized()     # Direction droite
		#var up = Vector3.UP                            # Toujours vers le haut
		#
		## Positions des deux rails
		#var left_rail_pos = pos + right * (rail_width * 0.5) + up * rail_height
		#var right_rail_pos = pos - right * (rail_width * 0.5) + up * rail_height
		#
		## Ajouter les vertices
		#vertices.append(left_rail_pos)
		#vertices.append(right_rail_pos)
		#
		## Normales (vers le haut)
		#normals.append(up)
		#normals.append(up)
		#
		## UVs pour le mapping de texture
		#var uv_v = t
		#uvs.append(Vector2(0, uv_v))
		#uvs.append(Vector2(1, uv_v))
	#
	## Créer les indices pour les triangles (quads = 2 triangles)
	#for i in range(steps):
		#var base = i * 2
		#
		## Rail gauche (quad)
		#indices.append(base)
		#indices.append(base + 2)
		#indices.append(base + 1)
		#
		#indices.append(base + 1)
		#indices.append(base + 2)
		#indices.append(base + 3)
	#
	## Créer la surface pour les rails
	#var arrays = []
	#arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = vertices
	#arrays[Mesh.ARRAY_NORMAL] = normals
	#arrays[Mesh.ARRAY_TEX_UV] = uvs
	#arrays[Mesh.ARRAY_INDEX] = indices
	#
	#array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#print_debug("Rails créés avec ", vertices.size(), " vertices et ", indices.size()/3, " triangles")
#
## Génération des traverses (sleepers/ties)
#func generate_rail_ties(array_mesh: ArrayMesh, curve: Curve3D):
	#var vertices = PackedVector3Array()
	#var normals = PackedVector3Array()
	#var uvs = PackedVector2Array()
	#var indices = PackedInt32Array()
	#
	#var curve_length = curve.get_baked_length()
	#var tie_count = int(curve_length / tie_spacing)
	#
	#print("Génération de ", tie_count, " traverses")
	#
	#var vertex_offset = 0
	#
	#for i in range(tie_count):
		#var distance = i * tie_spacing
		#var t = distance / curve_length
		#
		#if t > 1.0:
			#break
		#
		## Position et orientation de la traverse
		#var pos = curve.sample_baked(distance)
		#var transform = curve.sample_baked_with_rotation(distance)
		#var right = transform.basis.x.normalized()
		#var forward = -transform.basis.z.normalized()
		#var up = Vector3.UP
		#
		## Créer une traverse (parallélépipède)
		#var half_width = tie_width * 0.5
		#var half_height = tie_height * 0.5
		#var half_length = 0.2  ## Épaisseur de la traverse
		#
		## 8 vertices d'un cube pour chaque traverse
		#var tie_vertices = [
			#pos + right * half_width + up * half_height + forward * half_length,
			#pos - right * half_width + up * half_height + forward * half_length,
			#pos - right * half_width - up * half_height + forward * half_length,
			#pos + right * half_width - up * half_height + forward * half_length,
			#pos + right * half_width + up * half_height - forward * half_length,
			#pos - right * half_width + up * half_height - forward * half_length,
			#pos - right * half_width - up * half_height - forward * half_length,
			#pos + right * half_width - up * half_height - forward * half_length,
		#]
		#
		## Ajouter les vertices
		#for vertex in tie_vertices:
			#vertices.append(vertex)
			#normals.append(up)  # Normal simplifiée
			#uvs.append(Vector2(0, 0))  # UV simplifiée
		#
		## Indices pour les faces du cube (12 triangles = 6 faces)
		#var cube_indices = [
			## Face avant
			#0, 1, 2,  2, 3, 0,
			## Face arrière  
			#4, 7, 6,  6, 5, 4,
			## Face droite
			#0, 3, 7,  7, 4, 0,
			## Face gauche
			#1, 5, 6,  6, 2, 1,
			## Face dessus
			#0, 4, 5,  5, 1, 0,
			## Face dessous
			#3, 2, 6,  6, 7, 3
		#]
		#
		## Ajouter les indices avec l'offset
		#for index in cube_indices:
			#indices.append(vertex_offset + index)
		#
		#vertex_offset += 8
	#
	## Créer la surface pour les traverses
	#var arrays = []
	#arrays.resize(Mesh.ARRAY_MAX)
	#arrays[Mesh.ARRAY_VERTEX] = vertices
	#arrays[Mesh.ARRAY_NORMAL] = normals
	#arrays[Mesh.ARRAY_TEX_UV] = uvs
	#arrays[Mesh.ARRAY_INDEX] = indices
	#
	#array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	#print("Traverses créées avec ", vertices.size(), " vertices")
#
## Application du matériau
#func apply_rail_material():
	## Vérifier qu'on a bien un mesh
	#if not mesh:
		#print_debug("Aucun mesh trouvé pour appliquer les matériaux")
		#return
	#
	## Matériau pour les rails (métal brillant)
	#var rail_material = StandardMaterial3D.new()
	#rail_material.albedo_color = Color(0.3, 0.3, 0.3)
	#rail_material.metallic = 0.8
	#rail_material.roughness = 0.2
	#set_surface_override_material(0, rail_material)
	#
	## Matériau pour les traverses (bois) - seulement si la surface existe
	#var surface_count = mesh.get_surface_count()
	#if surface_count > 1:
		#var tie_material = StandardMaterial3D.new()
		#tie_material.albedo_color = Color(0.4, 0.2, 0.2)
		#tie_material.roughness = 0.8
		#set_surface_override_material(1, tie_material)
		#print_debug("Matériaux appliqués : ", surface_count, " surfaces")
	#else:
		#print_debug("Une seule surface détectée, matériau rails seulement")
#
## Fonction utilitaire pour recalculer les rails
#func regenerate_rails():
	#if path_to_follow:
		#generate_complete_rails()
		#print_debug("Rails régénérés")
