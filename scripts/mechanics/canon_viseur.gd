extends Area3D
# canon_3d.gd


@onready var cannon_mesh = %Bomber_1_Mid

# canon_3d_complete.gd


@export var rotation_speed: float = 50.0
@export var min_rotation: float = -45.0
@export var max_rotation: float = 45.0
@export var bullet_speed: float = 25.0
@export var min_bullet_speed: float = 5.0   # Vitesse minimum
@export var max_bullet_speed: float = 50.0  # Vitesse maximum
@export var speed_adjustment: float = 5.0   # Incrément de vitesse
@export var bullet_scene: PackedScene  # Glisse ton scène de balle ici
@export var dialogue_name : String = "tuto_canon"

@onready var firing_point = %Marker3D  # Position3D pour le point de tir
@onready var hero_pos: Marker3D = %hero_pos

var player = null
var current_rotation: float = 0.0
var can_use := false

func _ready():
	current_rotation = cannon_mesh.rotation_degrees.y
	
	#%Label3D.text = str(bullet_speed)

func _process(delta):
	if !can_use:
		return
	handle_rotation(delta)
	handle_bullet_speed_adjustment(delta)
	# Tir avec espace
	if Input.is_action_just_pressed("canon_fire"):  # Espace par défaut
		fire()
	if Input.is_action_just_pressed("ui_cancel"):
		can_use = false
		player.can_move = true

func handle_rotation(delta):
	var rotation_direction = 0.0
	
	if Input.is_action_pressed("ui_right"):
		rotation_direction = -1.0
	elif Input.is_action_pressed("ui_left"):
		rotation_direction = 1.0
	
	if rotation_direction != 0:
		current_rotation += rotation_direction * rotation_speed * delta
		current_rotation = clamp(current_rotation, min_rotation, max_rotation)
		cannon_mesh.rotation_degrees.y = current_rotation

func handle_bullet_speed_adjustment(_delta):
	var speed_changed = false
	
	# Augmenter la vitesse avec flèche HAUT
	if Input.is_action_just_pressed("ui_up"):
		bullet_speed += speed_adjustment
		bullet_speed = min(bullet_speed, max_bullet_speed)
		speed_changed = true
	
	# Diminuer la vitesse avec flèche BAS
	elif Input.is_action_just_pressed("ui_down"):
		bullet_speed -= speed_adjustment
		bullet_speed = max(bullet_speed, min_bullet_speed)
		speed_changed = true
	
	# Afficher la nouvelle vitesse si elle a changé
	if speed_changed:
		pass
		#%Label3D.text = str(bullet_speed)

func fire():
	if bullet_scene:
		# Instancier la balle
		var bullet = bullet_scene.instantiate()
		
		# Positionner la balle au point de tir
		bullet.global_transform = firing_point.global_transform
		
		# Ajouter à la scène
		get_tree().root.add_child(bullet)
		
		# Appliquer une force (selon la direction du canon)
		if bullet is RigidBody3D:
			var direction = -cannon_mesh.global_transform.basis.z
			bullet.linear_velocity = direction * bullet_speed


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		player = body
		body.position = hero_pos.global_position
		body.rotation = hero_pos.rotation
		body.can_move = false
		can_use = true
		if Dialogic.current_timeline != null:
			return
		if not Dialogic.timeline_ended.is_connected(_on_timeline_ended):
			Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start(dialogue_name)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Global.pausing = true
		Global.emit_on_pause_mode()
		get_viewport().set_input_as_handled()

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.pausing = false
	Global.emit_on_pause_mode()


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		can_use = false
		body.can_move = true
		player = null
		pass
