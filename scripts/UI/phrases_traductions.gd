extends CanvasLayer


@export_group("Phrases list")
@export var title : String = "test"
@export var fr_phrase : Array[String]

@export var pt_phrase : Array[String]
@export var audio_phrase : Array[AudioStream]

@export_group("Vocabulaire list")
#@export_multiline var vocab_list : String
@export var fr_vocab : Array[String]
@export var pt_vocab : Array[String]
@export var audio_vocab : Array[AudioStream]

@export_group("Couleurs du texte")
@export var color_fr: Color = Color.WHITE
@export var color_pt: Color = Color(0.6, 0.85, 1.0)

@export_group("Couleurs du vocabulaire")
@export var color_voc_fr: Color = Color.WHITE
@export var color_voc_pt: Color = Color(0.6, 0.85, 1.0)

@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var v_box_container_2: VBoxContainer = %VBoxContainer2

var player

func _ready() -> void:
	_on_word_collected()
	player = get_tree().get_first_node_in_group("Player")
	
	%TitleLabel.text = title
	
	for p in fr_phrase.size():

		# Ligne FR + boutons
		var hbox = HBoxContainer.new()
		v_box_container.add_child(hbox)

		# 🔊 Bouton audio
		var btn_audio = Button.new()
		btn_audio.text = "🔊"
		btn_audio.flat = true
		btn_audio.custom_minimum_size = Vector2(28, 28)
		hbox.add_child(btn_audio)
		btn_audio.disabled = p >= audio_phrase.size() or audio_phrase[p] == null
		audio_player.finished.connect(func():
			btn_audio.modulate = Color.WHITE
		)

		btn_audio.pressed.connect(func():
			btn_audio.modulate = Color(0.7, 0.7, 1.0)
			play_phrase_audio(p)
		)


		# Label FR
		var lbl_fr = Label.new()
		lbl_fr.text = fr_phrase[p]
		lbl_fr.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl_fr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_fr.add_theme_color_override("font_color", color_fr)
		hbox.add_child(lbl_fr)

		# ❓ Bouton traduction
		var btn_trad = Button.new()
		btn_trad.text = "?"
		btn_trad.scale = Vector2(2,2)
		btn_trad.flat = false
		btn_trad.custom_minimum_size = Vector2(28, 28)
		hbox.add_child(btn_trad)

		# Traduction
		var lbl_pt = Label.new()
		lbl_pt.text = pt_phrase[p]
		lbl_pt.visible = false
		lbl_pt.add_theme_color_override("font_color", color_pt)
		lbl_pt.modulate.a = 0.0
		v_box_container.add_child(lbl_pt)

		# Connexions
		btn_trad.pressed.connect(func():
			lbl_pt.visible = !lbl_pt.visible
			if lbl_pt.visible:
				var tween = create_tween()
				tween.tween_property(lbl_pt, "modulate:a", 1.0, 0.25)
		)

		btn_audio.pressed.connect(func():
			play_phrase_audio(p)
		)
		
	for i in fr_vocab.size():
		
		# Ligne FR + boutons
		var hbox2 = HBoxContainer.new()
		v_box_container_2.add_child(hbox2)
		
		# Label FR
		var lbl_fr2 = Label.new()
		lbl_fr2.text = fr_vocab[i]
		lbl_fr2.autowrap_mode = TextServer.AUTOWRAP_WORD
		lbl_fr2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_fr2.add_theme_color_override("font_color", color_voc_fr)
		hbox2.add_child(lbl_fr2)
		
		# Traduction
		var lbl_pt2 = Label.new()
		lbl_pt2.text = pt_vocab[i]
		lbl_pt2.add_theme_color_override("font_color", color_voc_pt)
		#lbl_pt2.modulate.a = 0.0
		hbox2.add_child(lbl_pt2)
		
		# 🔊 Bouton audio
		var btn_audio2 = Button.new()
		btn_audio2.text = "🔊"
		btn_audio2.flat = true
		btn_audio2.custom_minimum_size = Vector2(28, 28)
		hbox2.add_child(btn_audio2)
		btn_audio2.disabled = i >= audio_vocab.size() or audio_vocab[i] == null
		audio_player.finished.connect(func():
			btn_audio2.modulate = Color.WHITE
		)

		btn_audio2.pressed.connect(func():
			btn_audio2.modulate = Color(0.7, 0.7, 1.0)
			play_phrase_audio2(i)
		)
	
		

func play_phrase_audio(index: int) -> void:
	if index >= audio_phrase.size():
		return

	audio_player.stop()
	audio_player.stream = audio_phrase[index]
	audio_player.play()

func play_phrase_audio2(index: int) -> void:
	if index >= audio_vocab.size():
		return

	audio_player.stop()
	audio_player.stream = audio_vocab[index]
	audio_player.play()

# Add the vocabulary in the Dictionnary of the player

func _on_word_collected():
	for i in fr_vocab.size():
		Global.emit_signal("note_collected", 
			{fr_vocab[i]: pt_vocab[i]}, 
			title
		)
		Global.ajouter_mot(fr_vocab[i])

func _on_button_exit_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if player:
		player.can_move = true
	hide()


func _on_button_vocab_pressed() -> void:
	%Vocab_list.show()


func _on_button_exit_vocab_tab_pressed() -> void:
	%Vocab_list.hide()
