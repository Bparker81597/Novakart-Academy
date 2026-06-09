extends Node

signal progress_changed

const SAVE_PATH := "user://save.json"
const ALL_CHARACTERS := ["blaze_bolt", "finn_tide", "nova_spark", "dash_rocket"]
const DEFAULT_PROGRESS := {
	"unlocked_characters": ALL_CHARACTERS,
	"selected_character": "nova_spark",
	"collected_stickers": [],
	"races_completed": 0,
	"total_nova_stars": 0,
	"best_nova_stars": 0,
	"academy_student_badge": false,
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
		return false
	progress["academy_student_badge"] = true
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

func _earned_stickers(stars: int, character_id: String) -> Array[String]:
	var character_badges := {
		"blaze_bolt": "blaze_badge",
		"finn_tide": "finn_badge",
		"nova_spark": "nova_badge",
		"dash_rocket": "dash_badge",
	}
	var earned: Array[String] = ["sunny_finisher"]
	if character_badges.has(character_id):
		earned.append(character_badges[character_id])
	if stars >= 5:
		earned.append("star_collector")
	if stars >= 10:
		earned.append("perfect_stars")
	return earned
