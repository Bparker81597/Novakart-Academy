extends SceneTree

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)

	var adventure: AdventureData = catalog.get_adventure("lighthouse_hero")
	assert(adventure, "Lighthouse Hero AdventureData is missing.")
	assert(adventure.title == "Lighthouse Hero", "Adventure title is wrong.")
	assert(adventure.guide_character == "finn_tide", "Finn Tide must guide the adventure.")
	assert(adventure.objectives.size() == 3, "Adventure needs three objectives.")
	assert(not adventure.intro_dialogue.is_empty(), "Adventure intro dialogue is missing.")
	assert(not adventure.completion_dialogue.is_empty(), "Adventure completion dialogue is missing.")
	assert(not adventure.rewards.is_empty(), "Adventure rewards are missing.")

	assert(save_manager.start_adventure("lighthouse_hero"), "Adventure should start once.")
	assert(save_manager.is_adventure_active("lighthouse_hero"), "Adventure was not saved as active.")
	assert(not save_manager.start_adventure("lighthouse_hero"), "Adventure should not start twice.")
	save_manager.complete_mission_objective("lighthouse_hero", "visit_discovery_beach")
	for index: int in 5:
		save_manager.record_seashells(1)
	save_manager.record_coral_race(0)
	assert(save_manager.is_adventure_complete("lighthouse_hero"), "Adventure did not complete.")
	assert(not save_manager.is_adventure_active("lighthouse_hero"), "Completed adventure remained active.")
	assert(save_manager.progress.adventure_rewards.has("lighthouse_hero"), "Adventure rewards were not saved.")

	for scene_path: String in [
		"res://scenes/main/AdventureHall.tscn",
		"res://scenes/ui/DialoguePanel.tscn",
		"res://scenes/ui/AdventureCompletionScreen.tscn",
	]:
		var packed: PackedScene = load(scene_path)
		assert(packed, "Could not load %s" % scene_path)
		var instance := packed.instantiate()
		root.add_child(instance)
		await process_frame
		instance.queue_free()
		await process_frame

	var hall: Node = load("res://scenes/main/AdventureHall.tscn").instantiate()
	root.add_child(hall)
	await process_frame
	for node_path: String in ["Board/Card/GuidePortrait", "Board/Card/Title", "Board/Card/Guide", "Board/Card/Rewards", "Board/Card/Progress", "Board/Card/Action", "Board/Previous", "Board/Next", "Board/Count", "DialoguePanel", "AdventureCompletionScreen"]:
		assert(hall.has_node(node_path), "Adventure Hall is missing %s" % node_path)
	hall.queue_free()

	var hub: Node = load("res://scenes/hub/HubWorld.tscn").instantiate()
	root.add_child(hub)
	await process_frame
	assert(hub.has_node("AdventureHall"), "Academy Hub needs Adventure Hall.")
	assert(hub.get_node("AdventureZone").target_scene.ends_with("AdventureHall.tscn"), "Adventure Hall zone is not connected.")
	hub.queue_free()

	save_manager.progress = original_progress
	save_manager.save_progress()
	print("Sprint 11 story adventure framework checks passed.")
	quit()
