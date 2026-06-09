extends SceneTree

const CHARACTER_IDS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

func _initialize() -> void:
	await process_frame
	var content_catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var audio_manager := root.get_node("/root/AudioManager")

	for scene_path: String in [
		"res://scenes/main/CharacterIntro.tscn",
		"res://scenes/ui/CharacterPortraitCard.tscn",
		"res://scenes/ui/SpeechBubble.tscn",
		"res://scenes/ui/BadgePopup.tscn",
		"res://scenes/ui/CharacterParticleEffect.tscn",
	]:
		assert(load(scene_path), "Could not load %s" % scene_path)

	var intro: Node = load("res://scenes/main/CharacterIntro.tscn").instantiate()
	root.add_child(intro)
	await process_frame
	for character_id: String in CHARACTER_IDS:
		var profile: Dictionary = content_catalog.get_character(character_id)
		intro._show_character(character_id)
		assert(intro.get_node("Identity/Row/Text/Name").text == profile.name, "Wrong intro name for %s" % character_id)
		assert(intro.get_node("Identity/Row/Text/Type").text == profile.type, "Wrong intro type for %s" % character_id)
		assert(intro.get_node("SpeechBubble/Text").text == profile.intro_line, "Wrong intro speech for %s" % character_id)
		assert(intro.get_node("Catchphrase/Text").text.contains(profile.catchphrase), "Wrong intro catchphrase for %s" % character_id)

	audio_manager.play_character_greeting("blaze_bolt")
	audio_manager.play_catchphrase("finn_tide")
	audio_manager.play_button_confirm()

	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress["academy_student_badge"] = false
	save_manager.progress["collected_stickers"] = []
	assert(save_manager.unlock_academy_student_badge(), "Badge should unlock the first time.")
	assert(save_manager.has_sticker("academy_student"), "Academy Student sticker should unlock with the badge.")
	assert(not save_manager.unlock_academy_student_badge(), "Badge should not unlock twice.")
	save_manager.progress = original_progress
	save_manager.save_progress()

	assert(_source_contains("res://scripts/ui/menu_navigation.gd", "CharacterSelect.tscn"), "Title should route to Character Select.")
	assert(_source_contains("res://scripts/ui/character_select.gd", "CharacterIntro.tscn"), "Character Select should route to Character Intro.")
	assert(_source_contains("res://scripts/ui/character_intro_controller.gd", "HubWorld.tscn"), "Character Intro should route to Academy Hub.")
	assert(_source_contains("res://scenes/hub/HubWorld.tscn", "RaceScene.tscn"), "Race Center should route to the race.")

	print("Sprint 5 character introduction checks passed.")
	quit()

func _source_contains(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	return file != null and file.get_as_text().contains(text)
