extends Node

signal greeting_requested(character_id: String, catchphrase: String)
signal narration_requested(narration_id: String)

func play_character_greeting(character_id: String) -> void:
	var profile := ContentCatalog.get_character(character_id)
	var audio_path: String = profile.get("greeting_audio", "")
	greeting_requested.emit(character_id, profile.get("catchphrase", ""))
	if not audio_path.is_empty() and ResourceLoader.exists(audio_path):
		play_sound(load(audio_path))

func request_narration(narration_id: String) -> void:
	narration_requested.emit(narration_id)

func play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()
