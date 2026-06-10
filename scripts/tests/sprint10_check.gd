extends SceneTree

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)

	var mission: Dictionary = catalog.get_mission("lighthouse_hero")
	assert(mission.get("npc", "") == "finn_tide", "Finn Tide must guide Lighthouse Hero.")
	assert(mission.get("objectives", []).size() == 3, "Lighthouse Hero needs three objectives.")
	assert(mission.get("rewards", {}).get("badge", "") == "lighthouse_hero", "Lighthouse Hero badge reward is missing.")

	save_manager.visit_world("coral_coast")
	assert(save_manager.get_mission_state("lighthouse_hero").status == "active", "Mission did not start.")
	assert(not save_manager.has_passport_stamp("coral_coast"), "Passport stamp unlocked too early.")

	save_manager.complete_mission_objective("lighthouse_hero", "visit_discovery_beach")
	for index: int in 5:
		save_manager.record_seashells(1)
	assert(not save_manager.is_mission_complete("lighthouse_hero"), "Mission completed before the race.")
	save_manager.record_coral_race(0)
	assert(save_manager.is_mission_complete("lighthouse_hero"), "Mission did not complete.")
	assert(save_manager.has_badge("lighthouse_hero"), "Lighthouse Hero badge was not saved.")
	assert(save_manager.has_sticker("coral_coast_visitor"), "Coral Coast sticker was not saved.")
	assert(save_manager.has_passport_stamp("coral_coast"), "Coral Coast passport stamp was not saved.")

	for scene_path: String in [
		"res://scenes/ui/MissionTracker.tscn",
		"res://scenes/ui/MissionCompletePopup.tscn",
		"res://scenes/ui/RewardPopup.tscn",
	]:
		var packed: PackedScene = load(scene_path)
		assert(packed, "Could not load %s" % scene_path)
		var instance := packed.instantiate()
		root.add_child(instance)
		await process_frame
		instance.queue_free()
		await process_frame

	var hub: Node = load("res://scenes/worlds/CoralCoastHub.tscn").instantiate()
	root.add_child(hub)
	await process_frame
	for node_path: String in ["CanvasLayer/HUD/MissionTracker", "CanvasLayer/HUD/MissionCompletePopup", "CanvasLayer/HUD/RewardPopup"]:
		assert(hub.has_node(node_path), "Coral Coast Hub is missing %s" % node_path)
	hub.queue_free()

	var beach: Node = load("res://scenes/worlds/DiscoveryBeach.tscn").instantiate()
	root.add_child(beach)
	await process_frame
	assert(beach.has_node("CanvasLayer/HUD/MissionTracker"), "Discovery Beach needs the mission tracker.")
	beach.queue_free()

	var race: Node = load("res://scenes/worlds/WaveRiderRace.tscn").instantiate()
	root.add_child(race)
	await process_frame
	assert(race.has_node("HUD/MissionTracker"), "Wave Rider Raceway needs the mission tracker.")
	race.queue_free()

	save_manager.progress = original_progress
	save_manager.save_progress()
	print("Sprint 10 mission framework checks passed.")
	quit()
