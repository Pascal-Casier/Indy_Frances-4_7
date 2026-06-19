extends Node3D
var camrot_h := 0.0
var camrot_v := 0.0
@export var cam_v_max := 50.0
@export var cam_v_min := -30.0
@export var mouse_sensitivity := 0.1
var acceleration := 10.0
@onready var spring_arm_3d: SpringArm3D = $h/v/SpringArm3D
var zoom_min := 13.0
var zoom_max := 3.0

# Variables pour le shake
var shake_amount := 0.0
var shake_decay := 5.0  # Vitesse de diminution du shake
var original_camera_offset := Vector3.ZERO

func _ready() -> void:
	Global.mouse_sensitivity_changed.connect(_on_sensitivity_changed)
	mouse_sensitivity = Global.mouse_sensitiv
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.on_pause_mode.connect(pausing)
	
	# Sauvegarde la position initiale du SpringArm
	original_camera_offset = spring_arm_3d.position

func _on_sensitivity_changed(value: float):
	mouse_sensitivity = value

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camrot_h += event.relative.x * mouse_sensitivity
		camrot_v += event.relative.y * mouse_sensitivity
	if event.is_action_pressed("zoom_in"):
		if spring_arm_3d.spring_length > zoom_max:
			spring_arm_3d.spring_length = lerp(spring_arm_3d.spring_length, spring_arm_3d.spring_length -4, 0.09 )
	if event.is_action_pressed("zoom_out"):
		if spring_arm_3d.spring_length < zoom_min:
			spring_arm_3d.spring_length = lerp(spring_arm_3d.spring_length, spring_arm_3d.spring_length +4, 0.09 )
	
func _physics_process(delta: float) -> void:
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, -camrot_h, acceleration * delta)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camrot_v, acceleration * delta)
	
	# Applique le shake
	if shake_amount > 0:
		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
		var shake_offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		spring_arm_3d.position = original_camera_offset + shake_offset
	else:
		spring_arm_3d.position = original_camera_offset

# Fonction à appeler pour déclencher le shake
func add_shake(intensity: float) -> void:
	shake_amount += intensity

func pausing(on):
	set_physics_process(!on)
