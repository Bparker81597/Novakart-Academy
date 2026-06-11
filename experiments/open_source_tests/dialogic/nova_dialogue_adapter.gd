class_name NovaDialogueTestAdapter
extends Node

signal line_started(character_name: String, text: String)
signal voice_hook_requested(character_id: String, line_id: String)
signal conversation_finished

const TEST_TIMELINE := "res://experiments/open_source_tests/dialogic/timelines/academy_hello.dtl"
const CHARACTER_TIMELINES := {
	"blaze_bolt": "res://experiments/open_source_tests/dialogic/timelines/blaze_test.dtl",
	"finn_tide": "res://experiments/open_source_tests/dialogic/timelines/finn_test.dtl",
	"nova_spark": "res://experiments/open_source_tests/dialogic/timelines/nova_test.dtl",
	"dash_rocket": "res://experiments/open_source_tests/dialogic/timelines/dash_test.dtl",
}
const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

func _ready() -> void:
	var character_directory := DialogicResourceUtil.get_character_directory()
	for character_id: String in CHARACTER_IDS:
		character_directory[character_id] = "res://experiments/open_source_tests/dialogic/characters/%s.dch" % character_id
	DialogicResourceUtil.set_directory("dch", character_directory)
	Dialogic.Text.about_to_show_text.connect(_on_text_started)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func start_test_conversation() -> void:
	_start_timeline(TEST_TIMELINE)

func start_character_conversation(character_id: String) -> void:
	_start_timeline(CHARACTER_TIMELINES.get(character_id, TEST_TIMELINE))

func _start_timeline(timeline_path: String) -> void:
	if Dialogic.current_timeline:
		await Dialogic.end_timeline(true)
	Dialogic.start(timeline_path)

func continue_conversation() -> void:
	Dialogic.Inputs.handle_input()

func _on_text_started(info: Dictionary) -> void:
	var character: DialogicCharacter = info.get("character")
	var character_name := character.display_name if character else "Academy Guide"
	line_started.emit(character_name, info.get("text", ""))

func _on_dialogic_signal(argument: Variant) -> void:
	var parts := str(argument).split(":")
	if parts.size() == 3 and parts[0] == "voice":
		voice_hook_requested.emit(parts[1], parts[2])
		AudioManager.request_narration("%s_%s" % [parts[1], parts[2]])

func _on_timeline_ended() -> void:
	conversation_finished.emit()
