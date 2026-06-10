extends Node

signal progress_changed

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
		if world_id == "coral_coast" and unlock_sticker("coral_coast_visitor"):
			rewards.append("coral_coast_visitor")
	var stamps: Array = progress.get("passport_stamps", [])
	if world_id not in stamps:
		stamps.append(world_id)
		progress["passport_stamps"] = stamps
	save_progress()
	return rewards

func record_seashells(amount: int) -> Array[String]:
	var rewards: Array[String] = []
	progress["total_seashells"] = int(progress.get("total_seashells", 0)) + amount
	var missions: Dictionary = progress.get("missions", {})
	missions["coral_shell_hunt"] = min(int(missions.get("coral_shell_hunt", 0)) + amount, 5)
	progress["missions"] = missions
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
	save_progress()
	return rewards

func unlock_badge(badge_id: String) -> bool:
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
