extends SceneTree

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)

	assert(catalog.get_world("coral_coast").name == "Coral Coast", "Coral Coast world data is missing.")
	var visit_rewards: Array[String] = save_manager.visit_world("coral_coast")
	assert(visit_rewards.is_empty(), "Coral Coast mission rewards should not unlock on arrival.")
	assert(not save_manager.has_passport_stamp("coral_coast"), "Passport stamp should require mission completion.")
	assert(save_manager.get_mission_state("lighthouse_hero").status == "active", "Lighthouse Hero should start on arrival.")

	var shell_rewards: Array[String] = []
	for index: int in 5:
		shell_rewards.append_array(save_manager.record_seashells(1))
	assert(save_manager.progress.total_seashells == 5, "Seashell total was not saved.")
	assert(save_manager.progress.missions.coral_shell_hunt == 5, "Finn mission progress is wrong.")
	assert(save_manager.has_badge("ocean_explorer"), "Ocean Explorer badge did not unlock.")
	assert("shell_collector" in shell_rewards, "Shell Collector sticker did not unlock.")
	assert("ocean_explorer" in shell_rewards, "Ocean Explorer sticker did not unlock.")
	assert("wave_rider" in save_manager.record_coral_race(0), "Wave Rider sticker did not unlock.")

	for scene_path: String in [
		"res://scenes/worlds/CoralCoastHub.tscn",
		"res://scenes/worlds/DiscoveryBeach.tscn",
		"res://scenes/worlds/WaveRiderRaceway.tscn",
		"res://scenes/worlds/WaveRiderRace.tscn",
		"res://scenes/pickups/Seashell.tscn",
	]:
		var packed: PackedScene = load(scene_path)
		assert(packed, "Could not load %s" % scene_path)
		var instance := packed.instantiate()
		root.add_child(instance)
		await process_frame
		instance.queue_free()
		await process_frame

	var coral_hub: Node = load("res://scenes/worlds/CoralCoastHub.tscn").instantiate()
	root.add_child(coral_hub)
	await process_frame
	for node_path: String in ["Lighthouse", "PalmTrees", "Coral", "RaceZone", "BeachZone", "CanvasLayer/HUD/FinnPortrait", "CanvasLayer/HUD/Passport", "CanvasLayer/HUD/Mission"]:
		assert(coral_hub.has_node(node_path), "Coral Coast Hub is missing %s" % node_path)
	assert(coral_hub.get_node("RaceZone").target_scene.ends_with("WaveRiderRace.tscn"), "Race gate is not connected.")
	assert(coral_hub.get_node("BeachZone").target_scene.ends_with("DiscoveryBeach.tscn"), "Beach gate is not connected.")

	var discovery: Node = load("res://scenes/worlds/DiscoveryBeach.tscn").instantiate()
	root.add_child(discovery)
	await process_frame
	assert(discovery.has_node("DiscoverySigns"), "Discovery Beach needs educational signs.")
	for shell_name: String in ["Shell1", "Shell2", "Shell3", "Shell4", "Shell5"]:
		assert(discovery.has_node(shell_name), "Discovery Beach is missing %s" % shell_name)

	var race: Node = load("res://scenes/worlds/WaveRiderRace.tscn").instantiate()
	root.add_child(race)
	await process_frame
	assert(race.has_node("WaveRiderRaceway/CoralArches"), "Wave Rider Raceway needs coral arches.")
	assert(race.has_node("WaveRiderRaceway/OceanTunnels"), "Wave Rider Raceway needs ocean tunnels.")
	assert(race.has_node("WaveRiderRaceway/LighthouseFinish"), "Wave Rider Raceway needs lighthouse finish.")

	save_manager.progress = original_progress
	save_manager.save_progress()
	print("Sprint 9 Coral Coast expansion checks passed.")
	quit()
