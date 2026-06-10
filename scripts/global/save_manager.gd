extends Node

signal progress_changed
signal mission_progress_changed(mission_id: String)
signal mission_completed(mission_id: String, rewards: Dictionary)

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
	save_progress()
	return new_stickers

func visit_world(world_id: String) -> Array[String]:
	var rewards: Array[String] = []
	var visited: Array = progress.get("visited_worlds", [])
	if world_id not in visited:
		visited.append(world_id)
		progress["visited_worlds"] = visited
	if world_id == "coral_coast":
		start_mission("lighthouse_hero")
	save_progress()
	return rewards

func record_seashells(amount: int) -> Array[String]:
	var rewards: Array[String] = []
	progress["total_seashells"] = int(progress.get("total_seashells", 0)) + amount
	var missions: Dictionary = progress.get("missions", {})
	missions["coral_shell_hunt"] = min(int(missions.get("coral_shell_hunt", 0)) + amount, 5)
	progress["missions"] = missions
	advance_mission_objective("lighthouse_hero", "collect_seashells", amount)
	if int(missions["coral_shell_hunt"]) >= 5:
		if unlock_sticker("shell_collector"):
			rewards.append("shell_collector")
		if unlock_badge("ocean_explorer"):
			if unlock_sticker("ocean_explorer"):
				rewards.append("ocean_explorer")
	save_progress()
	return rewards

func record_coral_race(shells: int) -> Array[String]:
	var rewards := record_seashells(shells)
	if unlock_sticker("wave_rider"):
		rewards.append("wave_rider")
	complete_mission_objective("lighthouse_hero", "finish_wave_rider")
	save_progress()
	return rewards

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
	mission_completed.emit(mission_id, rewards)
	return true

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
