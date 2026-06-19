extends Node3D

@export var my_image : Texture2D
@export var dalle1_text :  String
@export var dalle2_text :  String
@export var correct_answer : String
@export var image_size_coeficient : float = 1.0
@export var titre : String

@onready var press_e_1: Label3D = %pressE1
@onready var my_text_1: Label3D = %my_text1
@onready var press_e_2: Label3D = %pressE2
@onready var my_text_2: Label3D = %my_text2
@onready var sprite_3d: Sprite3D = %Sprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sparks: GPUParticles3D = %sparks
@onready var flash: GPUParticles3D = %flash
@onready var fire: GPUParticles3D = %fire
@onready var smoke: GPUParticles3D = %smoke
@onready var titre_label: Label3D = %titre

var is_open : bool = false
var player = null

func _ready() -> void:
	#sprite_3d.texture = my_image
	set_normalized_texture(my_image, image_size_coeficient)
	my_text_1.text = dalle1_text
	my_text_2.text = dalle2_text
	titre_label.text = titre


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and press_e_1.visible:
		animation_player.play("pressed1")
		
		if dalle1_text == correct_answer and !is_open:
			await animation_player.animation_finished
			animation_player.play("open")
			await animation_player.animation_finished
			is_open = true
			
		else:
			if player and !is_open:
				explode()
				player.damage_received()
	
	elif event.is_action_pressed("interact") and press_e_2.visible:
		animation_player.play("pressed2")
		if dalle2_text == correct_answer and !is_open:
			await animation_player.animation_finished
			animation_player.play("open")
			await animation_player.animation_finished
			is_open = true
		else:
			if player and !is_open:
				explode()
				player.damage_received()
	
func explode():
	$AudioStreamPlayer.play()
	animation_player.play("spike")
	#sparks.emitting = true
	#flash.emitting = true
	#fire.emitting = true
	#smoke.emitting = true
	#$explosion/AudioStreamPlayer.play()
	
func _on_area_3d_1_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_1.show()
		player = body


func _on_area_3d_1_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_1.hide()
		player = null


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_2.show()
		player = body


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		press_e_2.hide()
		player = null

func set_normalized_texture(new_texture, desired_size = 1.0):
	sprite_3d.texture = new_texture
	var tex_width = new_texture.get_width()
	var tex_height = new_texture.get_height()
	var aspect_ratio = float(tex_width) / float(tex_height)
	
	# Normalisez la taille en fonction de la largeur
	sprite_3d.scale = Vector3(desired_size, desired_size / aspect_ratio, 1.0)
