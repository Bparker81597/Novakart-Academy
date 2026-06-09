extends SceneTree

func _initialize() -> void:
	await process_frame

	var hub: Node = load("res://scenes/hub/HubWorld.tscn").instantiate()
	root.add_child(hub)
	await process_frame
	assert(hub.has_node("CanvasLayer/HUD/ActivityPrompt"), "Hub needs a large activity prompt.")
	assert(hub.has_node("HubPlayer/CameraRig/Camera3D"), "Hub needs a follow camera.")
	assert(hub.get_node("HubPlayer/CameraRig/Camera3D").fov <= 64.0, "Hub camera should not zoom too far out.")
	assert(hub.get_node("CanvasLayer/HUD/Home").focus_mode == Control.FOCUS_NONE, "Space interaction must not trigger Home.")

	var expected_prompts := {
		"RaceZone": "PRESS SPACE TO RACE!",
		"StickerZone": "STICKER BOOK COMING SOON!",
		"LearningZone": "LEARNING LAB COMING SOON!",
		"GarageZone": "GARAGE COMING SOON!",
		"EventZone": "EVENTS COMING SOON!",
	}
	for zone_name: String in expected_prompts:
		var zone: Node = hub.get_node(zone_name)
		assert(zone.prompt_text == expected_prompts[zone_name], "Wrong prompt for %s" % zone_name)
		hub.show_activity_prompt(zone)
		assert(hub.get_node("CanvasLayer/HUD/ActivityPrompt").visible, "Prompt did not show for %s" % zone_name)
		assert(hub.get_node("CanvasLayer/HUD/ActivityPrompt/Row/Prompt").text == expected_prompts[zone_name], "Prompt UI did not update for %s" % zone_name)
		hub.hide_activity_prompt(zone)

	for building_name: String in ["RaceCenter", "StickerHall", "LearningLab", "Garage", "EventPavilion"]:
		var sign: Label3D = hub.get_node("%s/Sign" % building_name)
		assert(sign.font_size >= 48, "%s sign is too small." % building_name)

	var title: Node = load("res://scenes/main/MainMenu.tscn").instantiate()
	root.add_child(title)
	await process_frame
	for portrait_name: String in ["Blaze", "Finn", "Nova", "Dash"]:
		var portrait: Control = title.get_node("Showcase/%s" % portrait_name)
		assert(portrait.global_position.y >= 0.0 and portrait.global_position.y + portrait.size.y <= 720.0, "%s is clipped on the title screen." % portrait_name)

	var intro: Node = load("res://scenes/main/CharacterIntro.tscn").instantiate()
	root.add_child(intro)
	await process_frame
	assert(intro.get_node("Identity/Row/Text/Name").get_theme_font_size("font_size") >= 52, "Intro character name is too small.")
	assert(intro.get_node("PortraitCard").scale.x >= 1.08, "Intro portrait should be larger.")

	var race: Node = load("res://scenes/race/RaceScene.tscn").instantiate()
	root.add_child(race)
	await process_frame
	assert(race.get_node("HUD/StarCount").get_theme_font_size("font_size") >= 58, "Race star counter is too small.")
	assert(race.get_node("HUD/CharacterName").get_theme_font_size("font_size") >= 46, "Race character name is too small.")
	assert(race.get_node("HUD/DriveHint").text == "ARROWS DRIVE  •  SPACE BOOST", "Race control hint is not simple enough.")

	print("Sprint 6 Hub navigation and UI polish checks passed.")
	quit()
