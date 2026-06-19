extends Area3D

# Références aux nœuds enfants
@onready var tourelle_rotation = %Gun_3_Mid
@onready var canon_elevation = %Gun_3_Gun
@onready var bullet_nbr_lbl: Label3D = %bulletNbr
@onready var audio_stream_player_clic: AudioStreamPlayer = %AudioStreamPlayerClic
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var buy_ammo_panel: Control = $BuyAmmoPanel
@onready var line_edit: LineEdit = %LineEdit

@onready var original_mesh_position: Vector3 = canon_elevation.position

const HANDLE_COINS = preload("res://assets/sounds/sfx/handleCoins.ogg")
const SOFT_CLICK = preload("res://assets/sounds/sfx/soft-click.mp3")
# Limites de rotation (en degrés)
@export var rotation_horizontale_min: float = -180.0
@export var rotation_horizontale_max: float = 180.0
@export var rotation_verticale_min: float = -45.0
@export var rotation_verticale_max: float = 45.0
@export var bullet_speed: float = 25.0
@export var limit_number_shoot := false
@export var max_number_bullets := 15
@export var price_entered := 0
#@export var min_bullet_speed: float = 5.0   # Vitesse minimum
#@export var max_bullet_speed: float = 50.0  # Vitesse maximum
#@export var speed_adjustment: float = 5.0   # Incrément de vitesse
@export var bullet_scene: PackedScene  # Glisse ton scène de balle ici

# Sensibilité de la souris
@export var sensibilite_souris: float = 0.3
@onready var firing_point = %Marker3D  # Position3D pour le point de tir
@onready var hero_pos: Marker3D = %hero_pos
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

# Variables pour stocker la rotation actuelle
var rotation_horizontale: float = 0.0
var rotation_verticale: float = 0.0

var can_be_used := false
var can_fire := true
var player = null
var bullet_nb_index := 1
#tween variables
var original_position: Vector3
var recoil_distance: float = 0.5  # Distance du recul en unités

func _ready():
	# Capturer la souris si nécessaire
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_position = canon_elevation.position
	if limit_number_shoot:
		bullet_nb_index = max_number_bullets
	line_edit.text = ""
	line_edit.grab_focus()
	

func _input(event):
	if event is InputEventMouseMotion and can_be_used:
		# Calculer le delta de mouvement de la souris
		var delta_horizontal = -event.relative.x * sensibilite_souris
		var delta_vertical = -event.relative.y * sensibilite_souris
		
		# Appliquer la rotation avec les limites
		rotation_horizontale += delta_horizontal
		rotation_verticale -= delta_vertical
		
		# Limiter les rotations
		rotation_horizontale = clamp(rotation_horizontale, 
			rotation_horizontale_min, rotation_horizontale_max)
		rotation_verticale = clamp(rotation_verticale, 
			rotation_verticale_min, rotation_verticale_max)
		
		# Appliquer les rotations aux nœuds
		# Rotation horizontale sur la tourelle (axe Y)
		tourelle_rotation.rotation_degrees.y = rotation_horizontale
		
		# Rotation verticale sur l'élévation du canon (axe X)
		canon_elevation.rotation_degrees.x = rotation_verticale
	
	if event.is_action_pressed("fire") and can_be_used and can_fire:
		if limit_number_shoot and bullet_nb_index > 0:
			fire()
			bullet_nb_index -= 1
			bullet_nbr_lbl.show()
			bullet_nbr_lbl.text = str(bullet_nb_index)
			%BulletLbl.show()
			%BulletLbl.text = str(bullet_nb_index)
		elif limit_number_shoot and bullet_nb_index == 0:
			audio_stream_player_clic.stream = SOFT_CLICK
			audio_stream_player_clic.play()
			animation_player.play("zoom")
		elif !limit_number_shoot:
			fire()
			
	
	if event.is_action_pressed("interact") and %escLbl.visible:
		can_be_used = false
		if player:
			player.can_move = true
			player = null
			%Camera3D.current = false
			
func _process(delta):
	# Optionnel : contrôles clavier pour affiner
	if Input.is_action_pressed("ui_left"):
		rotation_horizontale -= 30.0 * delta
	if Input.is_action_pressed("ui_right"):
		rotation_horizontale += 30.0 * delta
	if Input.is_action_pressed("ui_up"):
		rotation_verticale -= 30.0 * delta
	if Input.is_action_pressed("ui_down"):
		rotation_verticale += 30.0 * delta
	
	# Appliquer les limites
	rotation_horizontale = clamp(rotation_horizontale, 
		rotation_horizontale_min, rotation_horizontale_max)
	rotation_verticale = clamp(rotation_verticale, 
		rotation_verticale_min, rotation_verticale_max)
	
	# Mettre à jour les rotations
	tourelle_rotation.rotation_degrees.y = rotation_horizontale
	canon_elevation.rotation_degrees.x = rotation_verticale

# Fonction pour réinitialiser la position
func reset_position():
	rotation_horizontale = 0.0
	rotation_verticale = 0.0
	tourelle_rotation.rotation_degrees.y = 0.0
	canon_elevation.rotation_degrees.x = 0.0

# Fonction pour obtenir la direction de tir
func get_firing_direction() -> Vector3:
	return canon_elevation.global_transform.basis.z

func fire():
	if bullet_scene:

		var tween = create_tween()

		# 1. Calcule la position de recul
		# On prend la position d'origine et on AJOUTE le recul sur Z
		var recoil_pos = original_mesh_position + Vector3(0, 0, recoil_distance)

		# 2. Animer vers la position de recul
		tween.tween_property(
			canon_elevation,
			"position",
			recoil_pos, # Vers la position de recul (en gardant le Y d'origine)
			0.1
		).set_trans(Tween.TRANS_QUAD)

		# 3. Animer le retour à la position d'origine
		tween.tween_property(
			canon_elevation,
			"position",
			original_mesh_position, # Retour à la position EXACTE de départ
			0.3
		).set_trans(Tween.TRANS_BOUNCE)	
	

		# Instancier la balle
		var bullet = bullet_scene.instantiate()
		
		# Positionner la balle au point de tir
		bullet.global_transform = firing_point.global_transform
		
		# Ajouter à la scène
		get_tree().root.add_child(bullet)
		
		# Appliquer une force (selon la direction du canon)
		if bullet is RigidBody3D:
			var direction = get_firing_direction()
			bullet.linear_velocity = direction * bullet_speed
		audio_stream_player.play()
		can_fire = false
		await get_tree().create_timer(0.5).timeout
		can_fire = true
		

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		if player:
			player.can_move = false
		var tween = create_tween()
		tween.tween_property(body, "position", hero_pos.global_position , 0.5)
		await tween.finished
		#%esc.show()
		%escLbl.show()
		#await get_tree().create_timer(0.5).timeout
		%Camera3D.current = true
		can_be_used = true
		%positionmark.hide()
		if limit_number_shoot:
			bullet_nbr_lbl.text = str(bullet_nb_index)
			bullet_nbr_lbl.show()
			%BulletLbl.show()
			%BulletLbl.text = str(bullet_nb_index)
			if bullet_nb_index == 0 :
				line_edit.text = ""
				line_edit.grab_focus()
				show_panel()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = null
		%positionmark.show()
		#%esc.hide()
		%escLbl.hide()
		bullet_nbr_lbl.hide()
		%BulletLbl.hide()

func show_panel() -> void:
	buy_ammo_panel.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func hide_panel() -> void:
	buy_ammo_panel.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_button_ok_pressed() -> void:
	
	if Global.coins >= price_entered:
		price_entered = line_edit.text.to_int()
		bullet_nb_index += price_entered
		bullet_nbr_lbl.text = str(bullet_nb_index)
		%BulletLbl.text = str(bullet_nb_index)
		audio_stream_player_clic.stream = HANDLE_COINS
		audio_stream_player_clic.play()
		Global.coins -= price_entered
		Global.emit_coins_updated()
		hide_panel()
	else:
		%alertpanel.show()
		await get_tree().create_timer(1.2).timeout
		%alertpanel.hide()
	


func _on_button_non_pressed() -> void:
	hide_panel()


func _on_line_edit_text_submitted(new_text: String) -> void:
	if !new_text.is_valid_int():
		line_edit.placeholder_text = "entrez un numéro !"
	elif new_text.is_valid_int():
		price_entered = new_text.to_int()


func _on_line_edit_text_changed(new_text: String) -> void:
	var clean_text = ""
	for c in new_text:
		if c in ["0","1","2","3","4","5","6","7","8","9"]:
			clean_text += c
		elif c == "-" and clean_text == "": # autorise le signe négatif au début
			clean_text += c

	# Si on a modifié le texte, on le remet à jour
	if new_text != clean_text:
		line_edit.text = clean_text
		line_edit.caret_column = clean_text.length()

	# Si la saisie est valide, on met à jour la variable
	if clean_text.is_valid_int():
		price_entered = clean_text.to_int()
	else:
		price_entered = 0  # ou null si tu veux indiquer "rien"
