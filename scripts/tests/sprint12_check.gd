extends SceneTree

const CHARACTERS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]

func _initialize() -> void:
	await process_frame
	var catalog := root.get_node("/root/ContentCatalog")
	var save_manager := root.get_node("/root/SaveManager")
	var original_progress: Dictionary = save_manager.progress.duplicate(true)
	save_manager.progress = save_manager.DEFAULT_PROGRESS.duplicate(true)

	assert(int(catalog.friendship.get("max_level", 0)) == 10, "Friendship max level must be 10.")
	for character_id: String in CHARACTERS:
		assert(catalog.get_friendship_character(character_id).get("rewards", []).size() >= 5, "%s needs friendship rewards." % character_id)
		assert(save_manager.get_friendship_level(character_id) == 1, "%s should start at friendship level 1." % character_id)

	var blaze_rewards: Array[Dictionary] = save_manager.award_friendship_xp("blaze_bolt", 100)
	assert(save_manager.get_friendship_level("blaze_bolt") == 2, "Blaze did not reach friendship level 2.")
	assert(save_manager.has_sticker("blaze_best_buddy"), "Blaze friendship sticker did not unlock.")
	assert(not blaze_rewards.is_empty(), "Friendship level-up should return rewards.")

	save_manager.award_friendship_xp("nova_spark", 5000)
	assert(save_manager.get_friendship_level("nova_spark") == 10, "Friendship should cap at level 10.")
	assert(save_manager.get_friendship_level_progress("nova_spark").current_xp == 0, "Max friendship should show a full-state instead of overflow.")
	for reward_id: String in ["nova_best_buddy", "nova_friend_chat", "nova_victory_pose", "nova_profile_frame", "nova_future_adventure"]:
		assert(reward_id in save_manager.get_friendship_rewards("nova_spark"), "Missing saved friendship reward %s." % reward_id)

	var before_visit: int = save_manager.get_friendship_xp("finn_tide")
	save_manager.visit_world("coral_coast")
	var after_visit: int = save_manager.get_friendship_xp("finn_tide")
	assert(after_visit > before_visit, "Visiting Finn's world should award friendship XP.")
	save_manager.visit_world("coral_coast")
	assert(save_manager.get_friendship_xp("finn_tide") == after_visit, "World visit friendship XP should only award once.")
	save_manager.record_seashells(1)
	assert(save_manager.get_friendship_xp("finn_tide") > after_visit, "World collectibles should award guide friendship XP.")

	var before_race: int = save_manager.get_friendship_xp("dash_rocket")
	save_manager.record_race(0, "dash_rocket")
	assert(save_manager.get_friendship_xp("dash_rocket") > before_race, "Finishing a race should award selected-character friendship XP.")

	var profile: Node = load("res://scenes/main/CharacterProfile.tscn").instantiate()
	root.add_child(profile)
	await process_frame
	assert(profile.has_node("FriendshipPanel"), "Character Profile needs FriendshipPanel.")
	for character_id: String in CHARACTERS:
		profile._show_profile(character_id)
		assert(profile.get_node("FriendshipPanel/Content/Header").text.contains("FRIENDSHIP LEVEL"), "Profile friendship level is missing.")
	profile._show_profile("nova_spark")
	assert(profile.get_node("FriendshipPanel").get_theme_stylebox("panel").border_width_left == 11, "Unlocked profile decoration is not visible.")
	profile.queue_free()

	var panel: Node = load("res://scenes/ui/FriendshipPanel.tscn").instantiate()
	root.add_child(panel)
	await process_frame
	panel.configure("finn_tide")
	assert(panel.get_node("Content/Progress").max_value == 100.0, "Friendship progress bar target is wrong.")
	panel.queue_free()

	save_manager.progress = original_progress
	save_manager.save_progress()
	print("Sprint 12 friendship progression checks passed.")
	quit()
