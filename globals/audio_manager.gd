extends AudioStreamPlayer

# Some sounds are preloaded as static as it's used common enough
static var audio_item_get : AudioStream = preload("res://assets/audio/sfx/item_get.wav")
static var audio_spell_card : AudioStream = preload("res://assets/audio/sfx/thunder_light.wav")

func play_audio(sound: AudioStream) -> void:
	set_stream(sound)
	play()
	#audio_node = AudioStreamPlayer2D.new()
	#audio_node.set_stream(audio_shoot)
	#parent.add_child(audio_node)

func play_item_get() -> void:
	play_audio(audio_item_get)

func play_spell_card() -> void:
	play_audio(audio_spell_card)
