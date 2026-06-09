extends Node

signal greeting_requested(character_id: String, catchphrase: String)
signal catchphrase_requested(character_id: String, catchphrase: String)
signal narration_requested(narration_id: String)
signal button_confirm_requested
signal sticker_unlock_requested(sticker_id: String)

var voice_enabled := true

func play_character_greeting(character_id: String) -> void:
	if not voice_enabled:
		return
	var profile := ContentCatalog.get_character(character_id)
	var audio_path: String = profile.get("greeting_audio", "")
	greeting_requested.emit(character_id, profile.get("catchphrase", ""))
	if not audio_path.is_empty() and ResourceLoader.exists(audio_path):
		play_sound(load(audio_path))

func play_catchphrase(character_id: String) -> void:
	if not voice_enabled:
		return
	var profile := ContentCatalog.get_character(character_id)
	catchphrase_requested.emit(character_id, profile.get("catchphrase", ""))

func play_button_confirm() -> void:
	button_confirm_requested.emit()

func play_sticker_unlock(sticker_id: String) -> void:
	sticker_unlock_requested.emit(sticker_id)
	var audio_path := "res://assets/audio/ui/sticker_unlock.wav"
	if ResourceLoader.exists(audio_path):
		play_sound(load(audio_path))

func request_narration(narration_id: String) -> void:
	if not voice_enabled:
		return
	narration_requested.emit(narration_id)

func play_sound(stream: AudioStream) -> void:
	if not stream:
		return
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()
