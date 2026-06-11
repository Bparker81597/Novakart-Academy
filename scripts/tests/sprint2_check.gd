extends SceneTree

func _initialize() -> void:
	await process_frame
	var content_catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	assert(content_catalog.characters.size() == 4, "Expected four character profiles.")
	assert(content_catalog.stickers.size() == 16, "Expected progression and friendship sticker definitions.")
	for character_id: String in ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]:
		var profile: Dictionary = content_catalog.get_character(character_id)
		for key: String in ["name", "type", "color_theme", "icon", "personality", "bio", "catchphrase", "intro_line", "ability", "favorite_activity", "portrait", "greeting_audio"]:
			assert(profile.has(key), "%s is missing %s" % [character_id, key])
		assert(ResourceLoader.exists(profile.portrait), "%s portrait asset is missing" % character_id)
	var expected_abilities := {
		"blaze_bolt": "Turbo Burst",
		"finn_tide": "Wave Rider",
		"nova_spark": "Rocket Boost",
		"dash_rocket": "Trail Blazer",
	}
	for character_id: String in expected_abilities:
		assert(content_catalog.get_character(character_id).ability == expected_abilities[character_id], "Wrong ability for %s" % character_id)
	for key: String in ["unlocked_characters", "selected_character", "collected_stickers", "races_completed", "total_nova_stars", "best_nova_stars", "academy_student_badge", "visited_worlds", "passport_stamps", "earned_badges", "total_seashells", "missions", "active_adventures", "completed_adventures", "adventure_rewards", "friendship", "friendship_world_visits", "friendship_rewards"]:
		assert(save_manager.progress.has(key), "Save progress is missing %s" % key)
	for scene_path: String in [
		"res://scenes/main/CharacterSelect.tscn",
		"res://scenes/main/CharacterProfile.tscn",
		"res://scenes/main/CharacterIntro.tscn",
		"res://scenes/main/StickerBook.tscn",
		"res://scenes/race/RaceScene.tscn",
		"res://scenes/ui/VictoryScreen.tscn",
	]:
		var scene: PackedScene = load(scene_path)
		assert(scene, "Could not load %s" % scene_path)
		var instance := scene.instantiate()
		root.add_child(instance)
		await process_frame
		if scene_path.ends_with("VictoryScreen.tscn"):
			var reward_ids: Array[String] = ["first_win"]
			instance.show_victory(7, 10, reward_ids)
			await create_timer(0.8).timeout
			assert(instance.visible, "Victory screen did not become visible.")
		if scene_path.ends_with("CharacterProfile.tscn"):
			for character_id: String in ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]:
				instance._show_profile(character_id)
				var character_profile: Dictionary = content_catalog.get_character(character_id)
				assert(instance.get_node("Details/Name").text == character_profile.name, "Wrong profile name for %s" % character_id)
				assert(instance.get_node("Details/Bio").text == character_profile.bio, "Wrong profile bio for %s" % character_id)
		if scene_path.ends_with("CharacterIntro.tscn"):
			for character_id: String in ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]:
				instance._show_character(character_id)
				var intro_profile: Dictionary = content_catalog.get_character(character_id)
				assert(instance.get_node("Identity/Row/Text/Name").text == intro_profile.name, "Wrong intro name for %s" % character_id)
				assert(instance.get_node("SpeechBubble/Text").text == intro_profile.intro_line, "Wrong intro line for %s" % character_id)
		if scene_path.ends_with("RaceScene.tscn"):
			var saved_profile: Dictionary = content_catalog.get_character(save_manager.get_selected_character())
			assert(instance.get_node("HUD/CharacterName").text == saved_profile.name.to_upper(), "HUD did not show selected character.")
		instance.queue_free()
		await process_frame
	print("Sprint 2 content, save, and UI checks passed.")
	quit()
