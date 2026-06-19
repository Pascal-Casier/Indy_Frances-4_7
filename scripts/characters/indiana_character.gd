extends CharacterBody3D

signal pressed_jump(jum_state : JumpState)
signal changed_stance(stance : Stance)
signal set_movement_state(_movement_state : MovementState)
signal set_movement_direction(_movement_direction : Vector3)

@export var max_air_jump : int = 1
@export var movement_states : Dictionary
@export var jump_states : Dictionary

var air_jump_counter : int = 0
var movement_direction : Vector3

var push_force := 25.0
var push_factor := 0.0

func _ready() -> void:
	set_movement_state.emit(movement_states["stand"])
	
func _input(event):
	if event.is_action_pressed("movement") or event.is_action_released("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
		if is_movement_ongoing():
			if Input.is_action_pressed("sprint"):
				set_movement_state.emit(movement_states["sprint"])
				%sword_rare_gltf.hide()

			else:
				if Input.is_action_pressed("walk"):
					set_movement_state.emit(movement_states["walk"])
				else:
					set_movement_state.emit(movement_states["run"])
		else:
			set_movement_state.emit(movement_states["stand"])
	
	if event.is_action_pressed("jump"):
		if air_jump_counter <= max_air_jump:
			var jump_name = "ground_jump"
			if air_jump_counter > 0:
				jump_name = "air_jump"
			
			pressed_jump.emit(jump_states[jump_name])
			air_jump_counter += 1
			
	
	if Input.is_action_just_pressed("show_sword"):
		show_sword()
		
				
func _physics_process(_delta):
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)
		
	if is_on_floor():
		air_jump_counter = 0
	elif air_jump_counter == 0:
		air_jump_counter = 1

	if air_jump_counter <= max_air_jump:
		if Input.is_action_just_pressed("jump"):
			var jump_name = "ground_jump"
			
			if air_jump_counter > 0:
				jump_name = "air_jump"
				
			pressed_jump.emit(jump_states[jump_name])
			air_jump_counter += 1
##handle interaction with rigidbodies#################
	push_factor = velocity.length()
	push_factor = clamp(push_factor, 1.5, 10)
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force * push_factor)
	###########################
		
func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0

func show_sword():
	%sword_rare_gltf.visible = !%sword_rare_gltf.visible
