class_name NovaQuestTestAdapter
extends Node

signal progress_changed(progress: Dictionary)
signal quest_completed

const QUEST_KEY := "sea_turtle_rescue"
const QUEST_PATH := "res://experiments/open_source_tests/quest_system/sea_turtle_rescue.tres"
const QUEST_SAVE_PATH := "user://quest_system_integration_test.json"
const REWARDS := {
	"badge": "ocean_helper",
	"sticker": "sea_turtle",
	"friendship_character": "finn_tide",
	"friendship_xp": 100,
	"passport_stamp": "coral_coast",
	"adventure": QUEST_KEY,
}

var quest: SeaTurtleRescueQuest
var quest_system: Node
var world_state: Node

func _ready() -> void:
	quest_system = get_node("/root/QuestSystem")
	world_state = get_node("/root/WorldState")
	quest = load(QUEST_PATH).duplicate(true)
	quest_system.reset_pool()
	quest_system.mark_quest_as_available(quest)
	quest_system.quest_completed.connect(_on_quest_system_completed)
	quest.updated.connect(_on_quest_updated)
	load_quest_progress()
	if not quest_system.is_quest_active(quest) and not quest_system.is_quest_completed(quest):
		quest_system.start_quest(quest)
		save_quest_progress()
	_sync_world_state()

func advance_objective(objective_id: String, amount: int = 1) -> void:
	if quest_system.is_quest_completed(quest):
		return
	quest_system.update_quest(quest, {"objective_id": objective_id, "amount": amount})
	if quest.objective_completed:
		quest_system.complete_quest(quest)

func get_progress() -> Dictionary:
	var result := {}
	for objective_id: String in SeaTurtleRescueQuest.OBJECTIVE_TARGETS:
		result[objective_id] = quest.get_objective_progress(objective_id)
	result["status"] = "complete" if quest_system.is_quest_completed(quest) else "active"
	return result

func save_quest_progress() -> void:
	var file := FileAccess.open(QUEST_SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Could not save isolated QuestSystem progress.")
		return
	file.store_string(JSON.stringify({
		"pools": quest_system.pool_state_as_dict(),
		"quests": quest_system.serialize_quests(),
	}, "\t"))

func load_quest_progress() -> void:
	if not FileAccess.file_exists(QUEST_SAVE_PATH):
		return
	var file := FileAccess.open(QUEST_SAVE_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
	if not parsed is Dictionary:
		return
	quest_system.reset_pool()
	var quests: Array[Quest] = [quest]
	quest_system.restore_pool_state_from_dict(parsed.get("pools", {}), quests)
	quest_system.deserialize_quests(parsed.get("quests", {}))

func reset_test_progress() -> void:
	quest_system.reset_pool()
	quest = load(QUEST_PATH).duplicate(true)
	quest_system.mark_quest_as_available(quest)
	quest.updated.connect(_on_quest_updated)
	quest_system.start_quest(quest)
	if FileAccess.file_exists(QUEST_SAVE_PATH):
		DirAccess.remove_absolute(QUEST_SAVE_PATH)
	world_state.reset_experiment_state()
	_sync_world_state()

func _on_quest_updated() -> void:
	save_quest_progress()
	_sync_world_state()
	progress_changed.emit(get_progress())

func _on_quest_system_completed(completed_quest: Quest) -> void:
	if completed_quest.id != quest.id:
		return
	save_quest_progress()
	_sync_world_state()
	world_state.complete_quest(QUEST_KEY, REWARDS)
	progress_changed.emit(get_progress())
	quest_completed.emit()

func _sync_world_state() -> void:
	for objective_id: String in SeaTurtleRescueQuest.OBJECTIVE_TARGETS:
		var objective := quest.get_objective_progress(objective_id)
		world_state.update_quest_progress(QUEST_KEY, objective_id, objective.current, objective.target)
