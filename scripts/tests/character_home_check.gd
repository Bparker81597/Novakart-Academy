extends SceneTree

const EXPECTED_HOMES := {
	"blaze_bolt": "blaze_garage",
	"finn_tide": "finn_dock",
	"nova_spark": "nova_workshop",
	"dash_rocket": "dash_launch_pad",
}

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)

	assert(catalog.homes.size() == EXPECTED_HOMES.size(), "Character home catalog should contain four homes.")
	for character_id: String in EXPECTED_HOMES:
		var home_data: HomeData = catalog.get_home_for_character(character_id)
		assert(home_data, "Missing home for %s." % character_id)
		assert(home_data.id == EXPECTED_HOMES[character_id], "Wrong home mapped to %s." % character_id)
		assert(not home_data.greeting.is_empty(), "%s needs a greeting." % home_data.id)
		assert(home_data.decorations.size() == 3, "%s needs three starter decorations." % home_data.id)
		assert(home_data.collectible_slots.size() >= 2, "%s needs future collectible displays." % home_data.id)

	var home: Node = load("res://scenes/homes/CharacterHome.tscn").instantiate()
	root.add_child(home)
	await process_frame
	assert(home.has_node("CharacterGreetingZone"), "Character home needs a greeting zone.")
	assert(home.has_node("Decorations/Decoration1"), "Character home needs decoration displays.")
	assert(home.has_node("CanvasLayer/HUD/FriendshipPanel"), "Character home needs friendship rewards context.")
	assert(home.has_node("CanvasLayer/HUD/CollectiblesPanel"), "Character home needs future collectible displays.")

	for character_id: String in EXPECTED_HOMES:
		var home_data: HomeData = catalog.get_home_for_character(character_id)
		home.configure_home(home_data)
		assert(home.get_node("HomeTitle").text.contains(home_data.home_name.to_upper()), "Home title did not update.")
		assert(home.get_node("CanvasLayer/HUD/Portrait").character_id == character_id, "Home portrait did not update.")
		assert(not home.get_node("CanvasLayer/HUD/RewardsPanel/List").text.is_empty(), "Friendship rewards display is empty.")
		assert(not home.get_node("CanvasLayer/HUD/CollectiblesPanel/List").text.is_empty(), "Collectibles display is empty.")
		assert(home.get_node("CanvasLayer/HUD/GreetingPanel/Text").text == home_data.greeting, "Greeting did not update.")

	home.configure_home(catalog.get_home("finn_dock"))
	assert(home.get_node("Decorations/Decoration2/Icon").text == "🔒", "Level-three decoration should begin locked.")
	save_manager.award_friendship_xp("finn_tide", 500)
	home.configure_home(catalog.get_home("finn_dock"))
	assert(home.get_node("Decorations/Decoration2/Icon").text == "🐚", "Friendship should unlock home decorations.")
	assert(home.get_node("Decorations/Decoration3/Icon").text == "🌊", "Higher friendship decoration should unlock.")

	home.show_character_greeting()
	assert(home.get_node("CanvasLayer/HUD/GreetingPanel").visible, "Character greeting should be visible in the greeting zone.")
	home.queue_free()

	save_manager.progress = original_progress
	save_manager.save_progress()
	print("Character home framework checks passed.")
	quit()
