extends Control

var voice_hook_count := 0

func _ready() -> void:
	$Adapter.line_started.connect(_on_line_started)
	$Adapter.voice_hook_requested.connect(_on_voice_hook_requested)
	$Adapter.conversation_finished.connect(_on_conversation_finished)
	await get_tree().process_frame
	_start_dialogue()

func _start_dialogue() -> void:
	voice_hook_count = 0
	$TestUI/Restart.visible = false
	$TestUI/Continue.visible = true
	$TestUI/Header/Status.text = "Starting four-hero conversation..."
	$Adapter.start_test_conversation()

func _continue_dialogue() -> void:
	AudioManager.play_button_confirm()
	$Adapter.continue_conversation()

func _restart_dialogue() -> void:
	_start_dialogue()

func _start_character_dialogue(character_id: String) -> void:
	voice_hook_count = 0
	$TestUI/Restart.visible = false
	$TestUI/Continue.visible = true
	$Adapter.start_character_conversation(character_id)

func _on_line_started(character_name: String, _text: String) -> void:
	$TestUI/Continue.visible = true
	$TestUI/Restart.visible = false
	$TestUI/Header/Status.text = "%s is speaking • portraits + names active • Space or Continue" % character_name

func _on_voice_hook_requested(character_id: String, line_id: String) -> void:
	voice_hook_count += 1
	$TestUI/Header/Status.text = "Voice-ready hook: %s / %s" % [character_id, line_id]

func _on_conversation_finished() -> void:
	$TestUI/Header/Status.text = "Dialogic test complete • %d voice-ready hooks received" % voice_hook_count
	$TestUI/Continue.visible = false
	$TestUI/Restart.visible = true
