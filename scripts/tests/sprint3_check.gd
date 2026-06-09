extends SceneTree

func _initialize() -> void:
	await process_frame
	var scenes := {
		"title": "res://scenes/main/MainMenu.tscn",
		"settings": "res://scenes/main/Settings.tscn",
		"characters": "res://scenes/main/CharacterSelect.tscn",
		"profile": "res://scenes/main/CharacterProfile.tscn",
		"intro": "res://scenes/main/CharacterIntro.tscn",
		"hub": "res://scenes/hub/HubWorld.tscn",
		"portrait": "res://scenes/ui/CharacterPortrait.tscn",
		"kid_button": "res://scenes/ui/BigKidButton.tscn",
		"floating_star": "res://scenes/ui/FloatingStar.tscn",
		"building_card": "res://scenes/hub/BuildingCard.tscn",
		"portrait_card": "res://scenes/ui/CharacterPortraitCard.tscn",
		"speech_bubble": "res://scenes/ui/SpeechBubble.tscn",
		"badge_popup": "res://scenes/ui/BadgePopup.tscn",
		"character_particles": "res://scenes/ui/CharacterParticleEffect.tscn",
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
	assert(title.get_script().resource_path == "res://scripts/ui/menu_navigation.gd", "Title screen navigation controller is missing.")

	var characters: Node = instances.characters
	assert(characters.get_node("CharacterCards").get_child_count() == 4, "Character Select needs four cards.")
	assert(characters.has_node("SelectedCharacter"), "Character Select needs a prominent selected banner.")
	for card: Node in characters.get_node("CharacterCards").get_children():
		assert(card.has_node("Content/Profile"), "Character card is missing Profile action.")
	assert(characters.get_node("Race").text.contains("MEET HERO"), "Character Select primary action should open the hero intro.")

	var profile: Node = instances.profile
	for detail_path: String in ["Portrait", "Details/Name", "Details/Bio", "Details/Catchphrase/Value", "Details/Ability/Value", "Details/FavoriteActivity/Value"]:
		assert(profile.has_node(detail_path), "Character profile is missing %s" % detail_path)

	var intro: Node = instances.intro
	for intro_path: String in ["PortraitCard", "Identity/Row/Icon", "Identity/Row/Text/Name", "Identity/Row/Text/Type", "SpeechBubble", "Catchphrase/Text", "Actions/StartAdventure", "Actions/ChooseAgain", "BadgePopup", "Particles"]:
		assert(intro.has_node(intro_path), "Character intro is missing %s" % intro_path)

	var hub: Node = instances.hub
	for zone_name: String in ["RaceZone", "StickerZone", "LearningZone", "GarageZone", "EventZone"]:
		assert(hub.has_node(zone_name), "Hub is missing %s" % zone_name)
	assert(hub.has_node("HubPlayer"), "Hub is missing a safe player controller.")
	assert(hub.has_node("CanvasLayer/HUD/WelcomePanel/Portrait"), "Hub is missing selected-character portrait.")
	for visual_name: String in ["RaceCenter", "StickerHall", "LearningLab", "Garage", "EventPavilion", "Trees", "Lamps", "Gardens", "FloatingStars"]:
		assert(hub.has_node(visual_name), "Hub visual polish is missing %s" % visual_name)

	print("Sprint 3 title, character card, and campus hub checks passed.")
	quit()
