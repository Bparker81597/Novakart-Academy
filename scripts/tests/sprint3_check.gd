extends SceneTree

func _initialize() -> void:
	await process_frame
	var scenes := {
		"title": "res://scenes/main/MainMenu.tscn",
		"settings": "res://scenes/main/Settings.tscn",
		"characters": "res://scenes/main/CharacterSelect.tscn",
		"hub": "res://scenes/hub/HubWorld.tscn",
		"portrait": "res://scenes/ui/CharacterPortrait.tscn",
		"kid_button": "res://scenes/ui/BigKidButton.tscn",
		"floating_star": "res://scenes/ui/FloatingStar.tscn",
		"building_card": "res://scenes/hub/BuildingCard.tscn",
	}
	var instances := {}
	for scene_name: String in scenes:
		var packed: PackedScene = load(scenes[scene_name])
		assert(packed, "Could not load %s" % scenes[scene_name])
		var instance := packed.instantiate()
		root.add_child(instance)
		await process_frame
		instances[scene_name] = instance

	var title: Node = instances.title
	for button_path: String in ["MenuPanel/StartRacing", "MenuPanel/Characters", "MenuPanel/StickerBook", "MenuPanel/Settings"]:
		assert(title.has_node(button_path), "Title screen missing %s" % button_path)
	for portrait_name: String in ["Blaze", "Finn", "Nova", "Dash"]:
		assert(title.has_node("Showcase/%s" % portrait_name), "Title screen missing %s portrait" % portrait_name)

	var characters: Node = instances.characters
	assert(characters.get_node("CharacterCards").get_child_count() == 4, "Character Select needs four cards.")
	assert(characters.has_node("SelectedCharacter"), "Character Select needs a prominent selected banner.")

	var hub: Node = instances.hub
	for zone_name: String in ["RaceZone", "StickerZone", "LearningZone", "GarageZone", "EventZone"]:
		assert(hub.has_node(zone_name), "Hub is missing %s" % zone_name)
	assert(hub.has_node("HubPlayer"), "Hub is missing a safe player controller.")
	assert(hub.has_node("CanvasLayer/HUD/WelcomePanel/Portrait"), "Hub is missing selected-character portrait.")
	for visual_name: String in ["RaceCenter", "StickerHall", "LearningLab", "Garage", "EventPavilion", "Trees", "Lamps", "Gardens", "FloatingStars"]:
		assert(hub.has_node(visual_name), "Hub visual polish is missing %s" % visual_name)

	print("Sprint 3 title, character card, and campus hub checks passed.")
	quit()
