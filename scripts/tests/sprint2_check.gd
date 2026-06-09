extends SceneTree

func _initialize() -> void:
	await process_frame
	var content_catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	assert(content_catalog.characters.size() == 4, "Expected four character profiles.")
	assert(content_catalog.stickers.size() == 7, "Expected seven sticker definitions.")
	for character_id: String in ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]:
		var profile: Dictionary = content_catalog.get_character(character_id)
		for key: String in ["name", "icon", "ability", "catchphrase"]:
			assert(profile.has(key), "%s is missing %s" % [character_id, key])
	for key: String in ["unlocked_characters", "collected_stickers", "races_completed", "total_nova_stars", "best_nova_stars"]:
		assert(save_manager.progress.has(key), "Save progress is missing %s" % key)
	for scene_path: String in [
		"res://scenes/main/CharacterSelect.tscn",
		"res://scenes/main/StickerBook.tscn",
		"res://scenes/ui/VictoryScreen.tscn",
	]:
		var scene: PackedScene = load(scene_path)
		assert(scene, "Could not load %s" % scene_path)
		var instance := scene.instantiate()
		root.add_child(instance)
		await process_frame
		if scene_path.ends_with("VictoryScreen.tscn"):
			var reward_ids: Array[String] = ["sunny_finisher"]
			instance.show_victory(7, 10, reward_ids)
			await process_frame
			assert(instance.visible, "Victory screen did not become visible.")
		instance.queue_free()
		await process_frame
	print("Sprint 2 content, save, and UI checks passed.")
	quit()
