extends Node3D

@export var health : int = 3
@export var arrow_speed : float = 35
@onready var arrow = preload("res://scenes/mechanics/arrow.tscn")
# movement rates in degrees
@export var elevation_speed_deg: float = 5.0
@export var rotation_speed_deg: float = 5.0
# elevation constraints in degrees
@export var min_elevation_deg: float = 0.0
@export var max_elevation_deg: float = 60.0

# Turret components:

@onready var body: Node3D = %Body # Component to be rotated
@onready var head: Node3D = %Head # Component to be elevated
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Turret should rotate to look at this object
@export var target: Node3D

# Rates and constraints converted to radians
@onready var elevation_speed: float = deg_to_rad(elevation_speed_deg)
@onready var rotation_speed: float = deg_to_rad(rotation_speed_deg)
@onready var min_elevation: float = deg_to_rad(min_elevation_deg)
@onready var max_elevation: float = deg_to_rad(max_elevation_deg)
@onready var contour: MeshInstance3D = %contour

# This is for disabling the turret if a vital component is null
var active: bool = true


func _ready() -> void:
	$Timer.stop()
	# Disable the turret if head, body, or target
	# is missing.
	if head == null or body == null or target == null:
		active = false
	

func _physics_process(delta: float) -> void:
	# If not active do nothing
	if not active:
		return
	# Move to point at target
	rotate_and_elevate(delta, target.global_position)


func rotate_and_elevate(delta: float, current_target:Vector3) -> void:

	var rotation_targ:Vector3 = get_projected(current_target - body.global_position, body.global_basis.y)

	rotation_targ = rotation_targ + body.global_position

	var y_angle:float = get_angle_to_target(body.global_position, rotation_targ, body.global_basis.z)

	var rotation_sign:float = sign(body.to_local(current_target).x)
	
	var final_y:float = rotation_sign * min(rotation_speed * delta, y_angle)
	body.rotate_y(final_y)
	
	var elevation_targ:Vector3 = get_projected(current_target - head.global_position, head.global_basis.x)

	elevation_targ = elevation_targ + head.global_position
	

	var x_angle:float = get_angle_to_target(head.global_position, elevation_targ, head.global_basis.z)
	
	# Elevate toward target.
	# Calculate sign to elevate up or down.
	# There's an extra negative sign because pitching up is negative.
	var elevation_sign:float = -sign(head.to_local(current_target).y)
	# Calculate step size and direction. Use min to avoid
	# over-rotating. Just snap to the desired angle if it's
	# less than what we would rotate this frame.
	var final_x:float = elevation_sign * min(elevation_speed * delta, x_angle)
	head.rotate_x(final_x)
	# Clamp elevation within limits.
	# Reverse and negate max and min because up is negative and
	# down is positive.
	head.rotation.x = clamp(
		head.rotation.x,
		-max_elevation, min_elevation
	)


func get_angle_to_target(seeker_pos:Vector3, target_pos:Vector3, facing_dir:Vector3) -> float:
	# Pre: target_pos is a Vector3 representing x,y,z
	# coordinates in space.
	# seeker_pos is a Vector3 representing x,y,z
	# coordinates in space.
	# facing_dir is a Vector3 representing the direction
	# we want to find the angle with respect to.
	# Post: Uses Law of Cosines to calculate and
	# return the difference between heading angle
	# (facing_dir) and global angle to target
	# (dir_to) in radians.
	# Typically, facing_dir will be -seeker.global_transform.basis.z
	# but it can be useful to ask about 
	# seeker.global_transform.basis.y to see if target
	# is above or below, or use seeker.global_transform.basis.x
	# to see if target is to the left or right.
	# Return value guaranteed to be between 0 and pi
	var dir_to = seeker_pos.direction_to(target_pos)
	# Normalizing IS necessary under certain circumstances.
	facing_dir = facing_dir.normalized()
	dir_to = dir_to.normalized()
	return acos(facing_dir.dot(dir_to))


func get_projected(pos:Vector3, normal:Vector3) -> Vector3:
	# Project position "pos" onto the plane with the given normal vector.
	# https://math.stackexchange.com/questions/728481/3d-projection-onto-a-plane
	# "projected" is the vector indicating how far above/below
	# the target is from the plane of rotation.
	normal = normal.normalized()
	var projection:Vector3 = (pos.dot(normal) / normal.dot(normal)) * normal
	# By subtracting projection from position, we get the
	# projected point.
	return pos - projection

func shoot():
	
	var b = arrow.instantiate()
	# Ajoutez la flèche à la scène principale plutôt qu'au Marker3D
	get_tree().current_scene.add_child(b)
	
	# Positionnez la flèche à la position globale du Marker3D
	b.global_position = %Marker3D.global_position
	b.global_transform.basis = %Marker3D.global_transform.basis
	b.apply_central_impulse(%Marker3D.global_transform.basis.z * arrow_speed)
	
func _on_timer_timeout() -> void:
	shoot()
	%AudioStreamPlayer3D.play()


func _on_interuptor_body_entered(body2: Node3D) -> void:
	if body2.is_in_group("Player"):
		audio_stream_player.play()
		$Timer.start()
		active = true
		contour.show()


func hit():
	queue_free()


func _on_area_3d_body_entered(body3: Node3D) -> void:
	if body3.is_in_group("Bullet"):
		queue_free()


func _on_area_3d_area_entered(_area: Area3D) -> void:
	%GPUParticles3DSmoke.emitting = true
	health -= 1
	if health == 1:
		%GPUParticles3DFire.emitting = true
	if health == 0:
		%explosionSound.play()
		hide()
		await get_tree().create_timer(1.0).timeout
		queue_free()


func _on_interuptor_body_exited(body3: Node3D) -> void:
	if body3.is_in_group("Player"):
		$Timer.stop()
		active = false
		contour.hide()
