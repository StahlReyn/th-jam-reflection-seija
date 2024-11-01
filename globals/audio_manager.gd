extends AudioStreamPlayer

# Some sounds are preloaded as static as it's used common enough
static var audio_shoot_default : AudioStream = preload("res://assets/audio/sfx/hit_noise_fade.wav")
static var audio_item_get : AudioStream = preload("res://assets/audio/sfx/item_get.wav")
static var audio_spell_card : AudioStream = preload("res://assets/audio/sfx/thunder_light.wav")

func play_audio(sound: AudioStream, volume = 0.0) -> void:
	var node = AudioStreamPlayer.new()
	node.stream = sound
	node.volume_db = volume
	add_child(node)
	node.play()
	await node.finished
	node.call_deferred("queue_free")
	
func play_audio_2d(sound: AudioStream, pos: Vector2, volume = 0.0) -> void:
	var node = AudioStreamPlayer2D.new()
	node.position = pos
	node.stream = sound
	node.volume_db = volume
	add_child(node)
	node.play()
	await node.finished
	node.call_deferred("queue_free")
	
func play_item_get() -> void:
	play_audio(audio_item_get)

func play_spell_card() -> void:
	play_audio(audio_spell_card)
