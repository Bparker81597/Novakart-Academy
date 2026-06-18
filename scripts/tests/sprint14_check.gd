extends SceneTree

const QUEST_SCENE := "res://experiments/open_source_tests/QuestIntegrationTest.tscn"
const QUEST_PATH := "res://experiments/open_source_tests/quest_system/sea_turtle_rescue.tres"
const QUEST_SAVE_PATH := "user://quest_system_integration_test.json"
const WORLD_SAVE_PATH := "user://quest_integration_world_state.json"

func _initialize() -> void:
	await process_frame
	assert(root.has_node("/root/QuestSystem"), "QuestSystem autoload is missing.")
	assert(root.has_node("/root/WorldState"), "WorldState autoload is missing.")
	var world_state: Node = root.get_node("/root/WorldState")
	var save_manager: Node = root.get_node("/root/SaveManager")
	assert(ResourceLoader.exists(QUEST_SCENE), "QuestIntegrationTest scene is missing.")
	assert(ResourceLoader.exists(QUEST_PATH), "Sea Turtle Rescue quest resource is missing.")

	var quest: SeaTurtleRescueQuest = load(QUEST_PATH)
	assert(quest.quest_name == "Sea Turtle Rescue", "Quest name is wrong.")
	assert(quest.quest_description.contains("Finn"), "Quest giver context is missing.")
	assert(SeaTurtleRescueQuest.OBJECTIVE_TARGETS.collect_seashells == 5, "Seashell target must be five.")

	var scene: Node = load(QUEST_SCENE).instantiate()
	root.add_child(scene)
	await process_frame
	var adapter: Node = scene.get_node("Adapter")
	adapter.reset_test_progress()
	await process_frame

	adapter.advance_objective("collect_seashells", 3)
	adapter.advance_objective("visit_discovery_beach")
	var partial: Dictionary = adapter.get_progress()
	assert(partial.collect_seashells.current == 3, "Partial seashell progress was not tracked.")
	assert(partial.visit_discovery_beach.current == 1, "Beach visit was not tracked.")
	assert(FileAccess.file_exists(QUEST_SAVE_PATH), "QuestSystem progress did not save.")
	assert(FileAccess.file_exists(WORLD_SAVE_PATH), "WorldState quest progress did not save.")

	scene.queue_free()
	await process_frame

	var reloaded_scene: Node = load(QUEST_SCENE).instantiate()
	root.add_child(reloaded_scene)
	await process_frame
	var reloaded_adapter: Node = reloaded_scene.get_node("Adapter")
	var reloaded: Dictionary = reloaded_adapter.get_progress()
	assert(reloaded.collect_seashells.current == 3, "Quest progress did not survive reload.")
	assert(reloaded.visit_discovery_beach.current == 1, "Quest objective state did not survive reload.")

	reloaded_adapter.advance_objective("collect_seashells", 2)
	reloaded_adapter.advance_objective("finish_wave_rider")
	await process_frame
	var completed: Dictionary = reloaded_adapter.get_progress()
	assert(completed.status == "complete", "QuestSystem did not complete the test quest.")

	var state: Dictionary = world_state.experiment_state
	assert("ocean_helper" in state.badges, "WorldState did not award Ocean Helper badge.")
	assert("sea_turtle" in state.stickers, "WorldState did not award Sea Turtle sticker.")
	assert("coral_coast" in state.passport_stamps, "WorldState did not award Coral Coast passport stamp.")
	assert(int(state.friendship_xp.get("finn_tide", 0)) == 100, "WorldState did not award Finn friendship XP.")
	assert("sea_turtle_rescue" in state.completed_adventures, "WorldState did not record adventure completion.")
	assert(not save_manager.has_badge("ocean_helper"), "QuestSystem test must not write production badges.")
	assert(not save_manager.has_sticker("sea_turtle"), "QuestSystem test must not write production stickers.")

	reloaded_adapter.reset_test_progress()
	reloaded_scene.queue_free()
	print("Sprint 14 isolated QuestSystem checks passed.")
	quit()
