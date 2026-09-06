extends CharacterBody3D

##############################
#### PARAMETERS ##############
##############################
@export_category("Flight Settings")
@export_range(1, 100) var speed: float = 10.0
@export_range(1, 100) var yaw_speed: float = 10.0
@export_range(1, 50) var pitch_speed: float = 10.0

@export_category("Visual Limits")
@export_range(10, 180, 1) var max_yaw: float = 70.0
@export_range(10, 180, 1) var max_roll: float = 70.0
@export_range(10, 180, 1) var max_pitch: float = 30.0

@export_category("Turbo & Smoothing")
@export_range(1.0, 3.0, 0.1) var turbo_modifier: float = 2.0
@export_range(0.1, 3.0, 0.1) var turbo_transition_time: float = 0.6
@export_range(3.0, 10.0, 0.5) var turbo_time: float = 5.0
@export_range(0.1, 20.0, 0.1) var mouse_smoothing: float = 5.0 # Légèrement augmenté pour la nouvelle formule

@export_category("Combat")
@export var fire_damage: int = 10 # Les dégâts par seconde ou par tick

@onready var fire_particles: GPUParticles3D = $"model/Dragon_animated/Skinned Mesh 0/MouthPivot/FireParticles"
@onready var fire_hitbox: Area3D = $"model/Dragon_animated/Skinned Mesh 0/MouthPivot/FireHitbox"

@onready var model = $model
@onready var animation_player: AnimationPlayer = $model/Dragon_animated/AnimationPlayer
@onready var jet_timer = $Jet_timer
@onready var flap_audio: AudioStreamPlayer = $FlapAudio
@onready var flap_sound_timer: Timer = $FlapTimer
@onready var roar_audio: AudioStreamPlayer = $RoarAudio

const DRAGON_FIRE = preload("uid://dhiuw37wyr7ji")
const DRAGON_ROAR = preload("uid://bgpblnx8llp43")


var is_in_turbo: bool = false
var speed_multiplier: float = 1.0
var _turbo_tween: Tween
var _smoothed_mouse_speed: Vector2 = Vector2.ZERO


@export var flap_interval: float = 0.6 # Temps entre chaque battement sonore

var _is_gliding: bool = false
var _anim_timer: Timer

#########################
# OVERRIDE FUNCTIONS
#########################
func _ready() -> void:
	jet_timer.timeout.connect(_turbo_off)
	# Création dynamique du timer d'animation
	_anim_timer = Timer.new()
	add_child(_anim_timer)
	_anim_timer.timeout.connect(_toggle_flight_animation)
	# Configuration du timer de son d'ailes
	flap_sound_timer.wait_time = flap_interval
	flap_sound_timer.timeout.connect(_play_flap_sound)
	# Lancement de la boucle au démarrage
	_start_flapping()
	# Désactiver le feu au démarrage
	fire_particles.emitting = false
	# 'monitoring' permet de savoir si l'Area3D cherche des collisions
	fire_hitbox.monitoring = false
	
# Remplacement de _process par _physics_process pour gérer les collisions
func _physics_process(delta: float) -> void:
	# Lissage de la souris rendu indépendant des chutes de framerate
	var raw_mouse_speed = _get_mouse_speed()
	var weight = 1.0 - exp(-mouse_smoothing * delta)
	_smoothed_mouse_speed = _smoothed_mouse_speed.lerp(raw_mouse_speed, weight)

	_pitch(delta)
	_yaw(delta)
	_move(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turbo") and not is_in_turbo:
		_turbo_on()
	# Gestion du souffle de feu
	if event.is_action_pressed("fire_breath"):
		_start_fire()
	#elif event.is_action_released("fire_breath"):
		#_stop_fire()

#########################
# MOVEMENT FUNCTIONS
#########################
func _move(_delta: float) -> void:
	# Ton script d'origine soustrayait le vecteur Z. L'avant est donc -Z[cite: 1].
	var forward_direction = -transform.basis.z 
	
	# On assigne la vélocité native du CharacterBody3D
	velocity = forward_direction * speed * speed_multiplier
	
	# Le moteur Godot prend le relais pour calculer le glissement contre les murs et les ruines
	move_and_slide()

func _pitch(delta: float) -> void:
	var mouse_speed = _smoothed_mouse_speed
	# On fait pivoter la racine (CharacterBody3D) de haut en bas[cite: 1]
	rotation_degrees.x += mouse_speed.y * delta * pitch_speed
	
	# Le modèle s'incline visuellement[cite: 1]
	var amount = abs(mouse_speed.y)
	var direction = sign(mouse_speed.y)
	model.rotation_degrees.x = lerp(0.0, max_pitch, amount) * direction

func _yaw(delta: float) -> void:
	var mouse_speed = _smoothed_mouse_speed
	# On fait pivoter la racine (CharacterBody3D) de gauche à droite[cite: 1]
	rotation_degrees.y += mouse_speed.x * delta * yaw_speed
	
	_roll_and_yaw_model(mouse_speed.x)

func _roll_and_yaw_model(mouse_speed_x: float) -> void:
	var amount = abs(mouse_speed_x)
	var direction = sign(mouse_speed_x)
	# Les inclinaisons visuelles du roulis et du lacet[cite: 1]
	model.rotation_degrees.y = lerp(0.0, max_yaw, amount) * direction
	model.rotation_degrees.z = lerp(0.0, max_roll, amount) * direction

#########################
# HELPER FUNCTIONS
#########################
func _get_mouse_speed() -> Vector2:
	# Conserve la logique Freelancer/Mouse-aim[cite: 1]
	var screen_center = get_viewport().size * 0.5
	var displacment = screen_center - get_viewport().get_mouse_position()
	displacment.x /= screen_center.x
	displacment.y /= screen_center.y
	return displacment

func _turbo_on() -> void:
	is_in_turbo = true
	jet_timer.start(turbo_time)
	_animate_speed(turbo_modifier)
	animation_player.speed_scale = 1.5

func _turbo_off() -> void:
	jet_timer.stop()
	is_in_turbo = false
	_animate_speed(1.0)
	animation_player.speed_scale = 1.0

func _animate_speed(target: float) -> void:
	if _turbo_tween:
		_turbo_tween.kill() 
	_turbo_tween = create_tween()
	_turbo_tween.tween_property(self, "speed_multiplier", target, turbo_transition_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

#########################
# ANIMATION FUNCTIONS
#########################
func _start_flapping() -> void:
	_is_gliding = false
	# Le "0.5" crée un fondu d'une demi-seconde entre le plané et le battement
	animation_player.play("Fly_Flap", 0.5) 
	_anim_timer.start(5.0)
	flap_sound_timer.start() # Le son retentit en boucle pendant qu'on bat des ailes
	_play_flap_sound() # Joue un son immédiatement au passage au battement

func _start_gliding() -> void:
	_is_gliding = true
	# Transition douce vers le plané
	animation_player.play("Fly_Glide", 0.5)
	roar_audio.stream = DRAGON_ROAR
	roar_audio.play()
	_anim_timer.start(3.0)
	flap_sound_timer.stop() # Coupe le son pendant le plané

func _toggle_flight_animation() -> void:
	if _is_gliding:
		_start_flapping()
	else:
		_start_gliding()
		
#########################
# COMBAT FUNCTIONS
#########################
func _start_fire() -> void:
	fire_particles.emitting = true
	fire_hitbox.monitoring = true
	roar_audio.stream = DRAGON_FIRE
	roar_audio.play()
	await get_tree().create_timer(4,2).timeout
	_stop_fire()
	# Optionnel : lancer une animation de la gueule ouverte si tu en as une
	# animation_player.play("Open_Mouth")

func _stop_fire() -> void:
	fire_particles.emitting = false
	fire_hitbox.monitoring = false
	# Optionnel : fermer la gueule


func _on_fire_hitbox_body_entered(body: Node3D) -> void:
	# Si l'objet touché possède une méthode pour prendre feu ou subir des dégâts
	if body.has_method("take_fire_damage"):
		body.take_fire_damage(fire_damage)

func _play_flap_sound() -> void:
	# Si le son joue déjà, on peut soit le laisser finir, soit le relancer proprement.
	# Pour éviter qu'il ne se coupe brutalement, on utilise un AudioStreamPlayer standard
	# ou on s'assure de le relancer.
	if flap_audio.playing:
		flap_audio.stop()
	
	flap_audio.pitch_scale = randf_range(0.9, 1.1) # Petite variation aléatoire
	flap_audio.play()
