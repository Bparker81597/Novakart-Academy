extends SceneTree

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]
const TEST_ROOT := "res://experiments/open_source_tests/dialogic/"

var heard_characters: Array[String] = []
var voice_hooks: Array[String] = []
var finished := false

func _initialize() -> void:
	await process_frame
	assert(root.has_node("/root/Dialogic"), "Dialogic autoload is missing.")
	assert(FileAccess.file_exists("res://addons/dialogic/plugin.cfg"), "Pinned Dialogic addon is missing.")
	assert(ResourceLoader.exists(TEST_ROOT + "timelines/academy_hello.dtl"), "Group test timeline is missing.")

	for character_id: String in CHARACTER_IDS:
		var character: DialogicCharacter = load(TEST_ROOT + "characters/%s.dch" % character_id)
		assert(character, "Dialogic character resource is missing for %s." % character_id)
		assert(not character.display_name.is_empty(), "%s needs a display name." % character_id)
		assert(character.default_portrait == "default", "%s needs a default portrait." % character_id)
		var portrait_path: String = character.portraits.default.export_overrides.image
		assert(ResourceLoader.exists(portrait_path), "%s portrait path cannot load." % character_id)
		assert(ResourceLoader.exists(TEST_ROOT + "timelines/%s_test.dtl" % character_id.trim_suffix("_bolt").trim_suffix("_tide").trim_suffix("_spark").trim_suffix("_rocket")), "%s test conversation is missing." % character_id)

	var scene: Node = load("res://experiments/open_source_tests/DialogueTest.tscn").instantiate()
	var adapter: Node = scene.get_node("Adapter")
	adapter.line_started.connect(_on_line_started)
	adapter.voice_hook_requested.connect(_on_voice_hook)
	adapter.conversation_finished.connect(_on_finished)
	root.add_child(scene)
	await process_frame
	for character_id: String in CHARACTER_IDS:
		var short_id := character_id.trim_suffix("_bolt").trim_suffix("_tide").trim_suffix("_spark").trim_suffix("_rocket")
		var timeline: DialogicTimeline = load(TEST_ROOT + "timelines/%s_test.dtl" % short_id)
		timeline.process()
		assert(timeline.events.size() >= 3, "%s test conversation did not parse." % character_id)
		assert(timeline.events[0] is DialogicTextEvent, "%s conversation must begin with dialogue." % character_id)

	for _step: int in 100:
		await create_timer(0.12).timeout
		if finished:
			break
		adapter.continue_conversation()

	assert(finished, "Dialogic group conversation did not finish.")
	print("Sprint 13 heard characters: ", heard_characters)
	print("Sprint 13 voice hooks: ", voice_hooks)
	for character_id: String in CHARACTER_IDS:
		var character: DialogicCharacter = load(TEST_ROOT + "characters/%s.dch" % character_id)
		assert(character.display_name in heard_characters, "%s did not speak." % character.display_name)
		assert(character_id in voice_hooks, "%s voice-ready hook did not fire." % character_id)
	assert(scene.get_node("TestUI/Continue") is Button, "Dialogue test needs a Continue button.")
	assert(scene.get_node("TestUI/ConversationPicker").get_child_count() == 4, "Dialogue test needs four character conversation buttons.")

	print("Sprint 13 isolated Dialogic checks passed.")
	await process_frame
	await process_frame
	quit()

func _on_line_started(character_name: String, _text: String) -> void:
	if character_name not in heard_characters:
		heard_characters.append(character_name)

func _on_voice_hook(character_id: String, _line_id: String) -> void:
	if character_id not in voice_hooks:
		voice_hooks.append(character_id)

func _on_finished() -> void:
	finished = true
