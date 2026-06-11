extends Node

signal progress_changed
signal mission_progress_changed(mission_id: String)
signal mission_completed(mission_id: String, rewards: Dictionary)
signal adventure_progress_changed(adventure_id: String)
signal adventure_completed(adventure_id: String)
signal friendship_changed(character_id: String, level: int, xp: int)
signal friendship_reward_unlocked(character_id: String, reward: Dictionary)

const SAVE_PATH := "user://save.json"
const ALL_CHARACTERS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]
const STICKER_ID_MIGRATION := {
	"sunny_finisher": "first_win",
	"blaze_badge": "blaze_fan",
	"finn_badge": "finn_fan",
	"nova_badge": "nova_fan",
	"dash_badge": "dash_fan",
}
const DEFAULT_PROGRESS := {
	"unlocked_characters": ALL_CHARACTERS,
	"selected_character": "nova_spark",
	"collected_stickers": [],
	"races_completed": 0,
	"total_nova_stars": 0,
	"best_nova_stars": 0,
	"academy_student_badge": false,
	"visited_worlds": ["academy_campus"],
	"passport_stamps": [],
	"earned_badges": [],
	"total_seashells": 0,
	"missions": {},
	"active_adventures": [],
	"completed_adventures": [],
	"adventure_rewards": {},
	"friendship": {},
	"friendship_world_visits": [],
	"friendship_rewards": {},
}

var progress: Dictionary = {}

func _ready() -> void:
	load_progress()

func load_progress() -> Dictionary:
	progress = DEFAULT_PROGRESS.duplicate(true)
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
		if parsed is Dictionary:
			progress.merge(parsed, true)
	_migrate_stickers()
	return progress

func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Could not save player progress.")
		return
	file.store_string(JSON.stringify(progress, "\t"))
	progress_changed.emit()

func is_character_unlocked(character_id: String) -> bool:
	return character_id in progress.get("unlocked_characters", [])

func get_selected_character() -> String:
	return progress.get("selected_character", "nova_spark")

func save_selected_character(character_id: String) -> void:
	if not is_character_unlocked(character_id):
		return
	progress["selected_character"] = character_id
	save_progress()

func unlock_academy_student_badge() -> bool:
	if progress.get("academy_student_badge", false):
		if unlock_sticker("academy_student"):
			save_progress()
		return false
	progress["academy_student_badge"] = true
	unlock_sticker("academy_student")
	save_progress()
	return true

func unlock_character(character_id: String) -> bool:
	var unlocked: Array = progress.get("unlocked_characters", [])
	if character_id in unlocked:
		return false
	unlocked.append(character_id)
	progress["unlocked_characters"] = unlocked
	save_progress()
	return true

func has_sticker(sticker_id: String) -> bool:
	return sticker_id in progress.get("collected_stickers", [])

func unlock_sticker(sticker_id: String) -> bool:
	var collected: Array = progress.get("collected_stickers", [])
	if sticker_id in collected:
		return false
	collected.append(sticker_id)
	progress["collected_stickers"] = collected
	return true

func record_race(stars: int, character_id: String) -> Array[String]:
	var new_stickers: Array[String] = []
	progress["races_completed"] = int(progress.get("races_completed", 0)) + 1
	progress["total_nova_stars"] = int(progress.get("total_nova_stars", 0)) + stars
	progress["best_nova_stars"] = max(int(progress.get("best_nova_stars", 0)), stars)
	for sticker_id: String in _earned_stickers(stars, character_id):
		if unlock_sticker(sticker_id):
			new_stickers.append(sticker_id)
	award_friendship_source(character_id, "race_finish")
	save_progress()
	return new_stickers

func visit_world(world_id: String) -> Array[String]:
	var rewards: Array[String] = []
	var visited: Array = progress.get("visited_worlds", [])
	if world_id not in visited:
		visited.append(world_id)
		progress["visited_worlds"] = visited
		var world := ContentCatalog.get_world(world_id)
		var guide_id: String = world.get("guide", "")
		if not guide_id.is_empty():
			award_friendship_world_visit(guide_id, world_id)
	if world_id == "coral_coast":
		start_adventure("lighthouse_hero")
	save_progress()
	return rewards

func record_seashells(amount: int) -> Array[String]:
	var rewards: Array[String] = []
	progress["total_seashells"] = int(progress.get("total_seashells", 0)) + amount
	var missions: Dictionary = progress.get("missions", {})
	missions["coral_shell_hunt"] = min(int(missions.get("coral_shell_hunt", 0)) + amount, 5)
	progress["missions"] = missions
	advance_mission_objective("lighthouse_hero", "collect_seashells", amount)
	award_friendship_source("finn_tide", "world_collectible", amount)
	if int(missions["coral_shell_hunt"]) >= 5:
		if unlock_sticker("shell_collector"):
			rewards.append("shell_collector")
		if unlock_badge("ocean_explorer"):
			if unlock_sticker("ocean_explorer"):
				rewards.append("ocean_explorer")
	save_progress()
	return rewards

func record_coral_race(shells: int, character_id: String = "") -> Array[String]:
	var rewards := record_seashells(shells)
	if unlock_sticker("wave_rider"):
		rewards.append("wave_rider")
	complete_mission_objective("lighthouse_hero", "finish_wave_rider")
	if not character_id.is_empty():
		award_friendship_source(character_id, "race_finish")
	save_progress()
	return rewards

func get_friendship(character_id: String) -> Dictionary:
	var all_friendship: Dictionary = progress.get("friendship", {})
	var state: Variant = all_friendship.get(character_id, {})
	if state is Dictionary and state.has("xp"):
		return state
	var new_state := {"xp": 0, "level": 1}
	all_friendship[character_id] = new_state
	progress["friendship"] = all_friendship
	return new_state

func get_friendship_level(character_id: String) -> int:
	return int(get_friendship(character_id).get("level", 1))

func get_friendship_xp(character_id: String) -> int:
	return int(get_friendship(character_id).get("xp", 0))

func get_friendship_level_progress(character_id: String) -> Dictionary:
	var xp := get_friendship_xp(character_id)
	var level := get_friendship_level(character_id)
	var per_level := int(ContentCatalog.friendship.get("xp_per_level", 100))
	var max_level := int(ContentCatalog.friendship.get("max_level", 10))
	return {
		"level": level,
		"current_xp": 0 if level >= max_level else xp % per_level,
		"needed_xp": per_level,
		"max_level": max_level,
	}

func award_friendship_source(character_id: String, source_id: String, multiplier: int = 1) -> Array[Dictionary]:
	return award_friendship_xp(character_id, ContentCatalog.get_friendship_source_xp(source_id) * multiplier)

func award_friendship_world_visit(character_id: String, world_id: String) -> Array[Dictionary]:
	var visit_id := "%s:%s" % [character_id, world_id]
	var visits: Array = progress.get("friendship_world_visits", [])
	if visit_id in visits:
		return []
	visits.append(visit_id)
	progress["friendship_world_visits"] = visits
	return award_friendship_source(character_id, "world_visit")

func award_friendship_xp(character_id: String, amount: int) -> Array[Dictionary]:
	var unlocked: Array[Dictionary] = []
	if character_id not in ALL_CHARACTERS or amount <= 0:
		return unlocked
	var state := get_friendship(character_id)
	var previous_level := int(state.get("level", 1))
	var per_level := int(ContentCatalog.friendship.get("xp_per_level", 100))
	var max_level := int(ContentCatalog.friendship.get("max_level", 10))
	var max_xp := (max_level - 1) * per_level
	state["xp"] = min(int(state.get("xp", 0)) + amount, max_xp)
	state["level"] = min(1 + int(state["xp"]) / per_level, max_level)
	for level: int in range(previous_level + 1, int(state["level"]) + 1):
		unlocked.append_array(_unlock_friendship_level_rewards(character_id, level))
	save_progress()
	friendship_changed.emit(character_id, int(state["level"]), int(state["xp"]))
	return unlocked

func get_friendship_rewards(character_id: String) -> Array:
	return progress.get("friendship_rewards", {}).get(character_id, [])

func _unlock_friendship_level_rewards(character_id: String, level: int) -> Array[Dictionary]:
	var unlocked: Array[Dictionary] = []
	var all_rewards: Dictionary = progress.get("friendship_rewards", {})
	var character_rewards: Array = all_rewards.get(character_id, [])
	for reward: Dictionary in ContentCatalog.get_friendship_character(character_id).get("rewards", []):
		if int(reward.get("level", 0)) != level or reward.get("id", "") in character_rewards:
			continue
		character_rewards.append(reward.id)
		unlocked.append(reward)
		if reward.get("type", "") == "sticker":
			unlock_sticker(reward.id)
	all_rewards[character_id] = character_rewards
	progress["friendship_rewards"] = all_rewards
	for reward: Dictionary in unlocked:
		friendship_reward_unlocked.emit(character_id, reward)
	return unlocked

func start_mission(mission_id: String) -> bool:
	var mission: Dictionary = ContentCatalog.get_mission(mission_id)
	if mission.is_empty():
		return false
	var missions: Dictionary = progress.get("missions", {})
	if missions.get(mission_id) is Dictionary:
		return false
	var objectives := {}
	for objective: Dictionary in mission.get("objectives", []):
		objectives[objective.id] = 0
	if mission_id == "lighthouse_hero":
		objectives["collect_seashells"] = min(int(missions.get("coral_shell_hunt", 0)), 5)
	missions[mission_id] = {
		"status": "active",
		"objectives": objectives,
		"rewards_claimed": false,
	}
	progress["missions"] = missions
	mission_progress_changed.emit(mission_id)
	save_progress()
	return true

func start_adventure(adventure_id: String) -> bool:
	var adventure := ContentCatalog.get_adventure(adventure_id)
	if not adventure:
		return false
	var active: Array = progress.get("active_adventures", [])
	var completed: Array = progress.get("completed_adventures", [])
	if adventure_id in completed or adventure_id in active:
		return false
	active.append(adventure_id)
	progress["active_adventures"] = active
	start_mission(adventure.mission_id)
	if is_mission_complete(adventure.mission_id):
		_complete_adventure_for_mission(adventure.mission_id, adventure.rewards)
	save_progress()
	adventure_progress_changed.emit(adventure_id)
	return true

func get_adventure_progress(adventure_id: String) -> Dictionary:
	var adventure := ContentCatalog.get_adventure(adventure_id)
	if not adventure:
		return {}
	var mission := ContentCatalog.get_mission(adventure.mission_id)
	var completed_count: int = 0
	var objective_count: int = mission.get("objectives", []).size()
	for objective: Dictionary in mission.get("objectives", []):
		if get_mission_objective_progress(adventure.mission_id, objective.id) >= int(objective.target):
			completed_count += 1
	return {
		"status": "complete" if adventure_id in progress.get("completed_adventures", []) else "active" if adventure_id in progress.get("active_adventures", []) else "available",
		"completed_objectives": completed_count,
		"total_objectives": objective_count,
	}

func is_adventure_active(adventure_id: String) -> bool:
	return adventure_id in progress.get("active_adventures", [])

func is_adventure_complete(adventure_id: String) -> bool:
	return adventure_id in progress.get("completed_adventures", [])

func advance_mission_objective(mission_id: String, objective_id: String, amount: int = 1) -> bool:
	start_mission(mission_id)
	var state := get_mission_state(mission_id)
	if state.get("status", "") == "complete":
		return false
	var target := _mission_objective_target(mission_id, objective_id)
	if target <= 0:
		return false
	var objectives: Dictionary = state.get("objectives", {})
	var previous := int(objectives.get(objective_id, 0))
	objectives[objective_id] = min(previous + amount, target)
	state["objectives"] = objectives
	mission_progress_changed.emit(mission_id)
	var adventure := ContentCatalog.get_adventure_for_mission(mission_id)
	if adventure:
		adventure_progress_changed.emit(adventure.id)
	_try_complete_mission(mission_id)
	save_progress()
	return int(objectives[objective_id]) != previous

func complete_mission_objective(mission_id: String, objective_id: String) -> bool:
	var target := _mission_objective_target(mission_id, objective_id)
	if target <= 0:
		return false
	var current := get_mission_objective_progress(mission_id, objective_id)
	return advance_mission_objective(mission_id, objective_id, target - current)

func get_mission_state(mission_id: String) -> Dictionary:
	var missions: Dictionary = progress.get("missions", {})
	var state: Variant = missions.get(mission_id, {})
	return state if state is Dictionary else {}

func get_mission_objective_progress(mission_id: String, objective_id: String) -> int:
	return int(get_mission_state(mission_id).get("objectives", {}).get(objective_id, 0))

func is_mission_complete(mission_id: String) -> bool:
	return get_mission_state(mission_id).get("status", "") == "complete"

func _try_complete_mission(mission_id: String) -> bool:
	var mission := ContentCatalog.get_mission(mission_id)
	var state := get_mission_state(mission_id)
	for objective: Dictionary in mission.get("objectives", []):
		if get_mission_objective_progress(mission_id, objective.id) < int(objective.target):
			return false
	state["status"] = "complete"
	var rewards: Dictionary = mission.get("rewards", {}).duplicate(true)
	if not state.get("rewards_claimed", false):
		unlock_badge(rewards.get("badge", ""))
		unlock_sticker(rewards.get("sticker", ""))
		_unlock_passport_stamp(rewards.get("passport_stamp", ""))
		state["rewards_claimed"] = true
	save_progress()
	_complete_adventure_for_mission(mission_id, rewards)
	mission_completed.emit(mission_id, rewards)
	return true

func _complete_adventure_for_mission(mission_id: String, rewards: Dictionary) -> void:
	var adventure := ContentCatalog.get_adventure_for_mission(mission_id)
	if not adventure:
		return
	var active: Array = progress.get("active_adventures", [])
	var completed: Array = progress.get("completed_adventures", [])
	active.erase(adventure.id)
	var first_completion := adventure.id not in completed
	if first_completion:
		completed.append(adventure.id)
	progress["active_adventures"] = active
	progress["completed_adventures"] = completed
	var earned: Dictionary = progress.get("adventure_rewards", {})
	earned[adventure.id] = rewards.duplicate(true)
	progress["adventure_rewards"] = earned
	if first_completion:
		award_friendship_source(adventure.guide_character, "adventure_complete")
	save_progress()
	adventure_completed.emit(adventure.id)

func _mission_objective_target(mission_id: String, objective_id: String) -> int:
	for objective: Dictionary in ContentCatalog.get_mission(mission_id).get("objectives", []):
		if objective.get("id", "") == objective_id:
			return int(objective.get("target", 0))
	return 0

func _unlock_passport_stamp(world_id: String) -> bool:
	if world_id.is_empty():
		return false
	var stamps: Array = progress.get("passport_stamps", [])
	if world_id in stamps:
		return false
	stamps.append(world_id)
	progress["passport_stamps"] = stamps
	return true

func unlock_badge(badge_id: String) -> bool:
	if badge_id.is_empty():
		return false
	var badges: Array = progress.get("earned_badges", [])
	if badge_id in badges:
		return false
	badges.append(badge_id)
	progress["earned_badges"] = badges
	return true

func has_badge(badge_id: String) -> bool:
	return badge_id in progress.get("earned_badges", [])

func has_passport_stamp(world_id: String) -> bool:
	return world_id in progress.get("passport_stamps", [])

func _earned_stickers(stars: int, character_id: String) -> Array[String]:
	var character_fans := {
		"blaze_bolt": "blaze_fan",
		"finn_tide": "finn_fan",
		"nova_spark": "nova_fan",
		"dash_rocket": "dash_fan",
	}
	var earned: Array[String] = ["first_win"]
	if int(progress.get("races_completed", 0)) == 1:
		earned.append("first_race")
	if character_fans.has(character_id):
		earned.append(character_fans[character_id])
	if stars >= 5:
		earned.append("star_collector")
	return earned

func _migrate_stickers() -> void:
	var migrated: Array = []
	for sticker_id: String in progress.get("collected_stickers", []):
		var new_id: String = STICKER_ID_MIGRATION.get(sticker_id, sticker_id)
		if new_id in ContentCatalog.stickers and new_id not in migrated:
			migrated.append(new_id)
	if progress.get("academy_student_badge", false) and "academy_student" not in migrated:
		migrated.append("academy_student")
	progress["collected_stickers"] = migrated
