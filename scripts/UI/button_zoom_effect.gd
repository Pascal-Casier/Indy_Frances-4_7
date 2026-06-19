extends Button

@export var hover_sound: AudioStream  # Son au survol
@export var click_sound: AudioStream  # Son au clic
@export var pitch_variation: bool = true
@export var min_pitch: float = 0.9
@export var max_pitch: float = 1.1

var tween_zoom: Tween
var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer

func _ready() -> void:
	pivot_offset = size / 2
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)
	
	# AudioPlayer pour le survol
	hover_player = AudioStreamPlayer.new()
	add_child(hover_player)
	if hover_sound:
		hover_player.stream = hover_sound
	
	# AudioPlayer pour le clic
	click_player = AudioStreamPlayer.new()
	add_child(click_player)
	if click_sound:
		click_player.stream = click_sound

func _on_mouse_entered() -> void:
	# Animation de zoom
	if tween_zoom:
		tween_zoom.kill()
	
	tween_zoom = create_tween()
	tween_zoom.set_trans(Tween.TRANS_ELASTIC)
	tween_zoom.set_ease(Tween.EASE_OUT)
	tween_zoom.tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	
	# Son de survol
	if hover_player and hover_player.stream:
		if pitch_variation:
			hover_player.pitch_scale = randf_range(min_pitch, max_pitch)
		hover_player.play()

func _on_mouse_exited() -> void:
	if tween_zoom:
		tween_zoom.kill()
	
	tween_zoom = create_tween()
	tween_zoom.set_trans(Tween.TRANS_ELASTIC)
	tween_zoom.set_ease(Tween.EASE_OUT)
	tween_zoom.tween_property(self, "scale", Vector2.ONE, 0.3)

func _on_button_pressed() -> void:
	if click_player and click_player.stream:
		if pitch_variation:
			click_player.pitch_scale = randf_range(min_pitch, max_pitch)
		click_player.play()
