extends CharacterBody3D

signal health_update()
@export var base_speed := 7.0
@export var run_speed := 10.0
@export var defend_speed := 2.0
var speed_modifier := 1.0
@export var can_double_jump := false
var has_double_jumped := false

var health := 100

#jump
@export var jump_height :float = 4.0
@export var jump_time_to_peak :float = 0.4
@export var jump_time_to_descent :float = 0.6

@onready var jump_velocity :float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity :float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity :float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))

#@onready var camera: Camera3D = $SpringArmPivot/Camera3D
@onready var camera: Camera3D = %Camera3D

@onready var skin: Node3D = $IndianaSkin
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var right_hand_slot: BoneAttachment3D = $IndianaSkin/init/GeneralSkeleton/RightHandSlot

######## fall Damage mechanic ################
var old_vel : float = 0.0
@export var fall_damage_thresold = 20
##############################################

var movement_input := Vector2.ZERO
var defend := false:
	set(value):
		if not defend and value and $IndianaSkin/init/GeneralSkeleton/LeftHanSlot/Skeleton_Shield_Small_A2.visible: #if not defending but want to
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value

var weapon_active : bool = true

func _ready() -> void:
	skin.switch_weapon(weapon_active)
	health_update.emit(health)

func _physics_process(delta: float) -> void:
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	if Input.is_action_just_pressed("show_sword"):
		show_weapon(not $IndianaSkin/init/GeneralSkeleton/RightHandSlot.visible)
	####### Handle fall damage###############
	if old_vel < 0:
		var diff = velocity.y - old_vel
		if diff > fall_damage_thresold and is_on_floor():
			damage_received()
	old_vel = velocity.y
	##########################################
	move_and_slide()

func move_logic(delta) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "back").rotated(-camera.global_rotation.y)
	var vel_2d = Vector2(velocity.x, velocity.z)
	var is_running :bool = Input.is_action_pressed("sprint")
	if movement_input != Vector2.ZERO:   # if player try to move
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		
		vel_2d += movement_input * speed * 8.0 * delta
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state("Running")
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, 6.0 * delta)
		match speed :
			base_speed:
				skin.adjust_speed(0.8)
			run_speed:
				skin.adjust_speed(1.4)
			defend_speed:
				skin.adjust_speed(0.6)
				
	else:       #if player tries to stop
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 5.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		skin.set_move_state("Idle")
		
func jump_logic(delta) -> void:
	if is_on_floor():
		has_double_jumped = false
		
		has_double_jumped = false
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_velocity
			do_squash_and_strech(1.2, 0.15)
	else:
		skin.set_move_state("Jump")
		if Input.is_action_just_pressed("jump") and not has_double_jumped and can_double_jump:
			velocity.y = -jump_velocity * 0.8 #force réduite pour le double saut
			has_double_jumped = true
			do_squash_and_strech(1.2, 0.15) 
		
		if Input.is_action_just_pressed("jump") and not has_double_jumped and can_double_jump:
			velocity.y = -jump_velocity * 0.8 #force réduite pour le double saut
			has_double_jumped = true
			do_squash_and_strech(1.2, 0.15) 
		
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity  # jumping or falling state
	velocity.y += gravity * delta

func ability_logic() -> void:
	#actual attack
	if Input.is_action_just_pressed("fire") and right_hand_slot.visible:
		if weapon_active:
			skin.attack()
		else:
			skin.cast_spell()
			stop_movement(0.3, 2.3)
	#defend
	defend = Input.is_action_pressed("aim") #aim = RMbtn
	
	#switch weapon / magic
	if Input.is_action_just_pressed("switch weapon") and not skin.attacking:
		weapon_active = not weapon_active
		skin.switch_weapon(weapon_active)
		do_squash_and_strech(1.2, 0.15)
	
	if Input.is_action_just_pressed("fire") and right_hand_slot.visible:
		stop_movement(0.6, 1.0)
		
func stop_movement(start_duration : float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	skin.hit()
	stop_movement(0.3, 0.3)

func do_squash_and_strech(value: float, duration: float =0.1) -> void:
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)

func show_weapon(value : bool) -> void:
	$IndianaSkin/init/GeneralSkeleton/RightHandSlot.visible = value
	do_squash_and_strech(1.2, 0.1)

func damage_received():
	audio_stream_player.play()
	do_squash_and_strech(1.2, 0.2)
	$Hurt_overlay.show()
	health -= 10
	health_update.emit(health)
	await get_tree().create_timer(0.2).timeout
	$Hurt_overlay.hide()
	
	if health > 0:
		hit()
		
	elif health <= 0 :
		set_physics_process(false)
		skin.die()
		await get_tree().create_timer(4.5).timeout
		global_transform.origin = Vector3.ZERO
		health = 100
		health_update.emit(100)
		set_physics_process(true)
