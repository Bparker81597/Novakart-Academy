extends Node

signal quest_progress_changed(quest_id: String, progress: Dictionary)
signal quest_completed(quest_id: String)
signal reward_awarded(reward_type: String, reward_id: String, amount: int)

const EXPERIMENT_SAVE_PATH := "user://quest_integration_world_state.json"
const DEFAULT_EXPERIMENT_STATE := {
	"quests": {},
	"badges": [],
	"stickers": [],
	"passport_stamps": [],
	"friendship_xp": {},
	"completed_adventures": [],
}

var experiment_state: Dictionary = {}

func _ready() -> void:
	load_experiment_state()

func load_experiment_state() -> Dictionary:
	experiment_state = DEFAULT_EXPERIMENT_STATE.duplicate(true)
	if FileAccess.file_exists(EXPERIMENT_SAVE_PATH):
		var file := FileAccess.open(EXPERIMENT_SAVE_PATH, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(file.get_as_text()) if file else null
		if parsed is Dictionary:
			experiment_state.merge(parsed, true)
	return experiment_state

func save_experiment_state() -> void:
	var file := FileAccess.open(EXPERIMENT_SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Could not save isolated QuestSystem world state.")
		return
	file.store_string(JSON.stringify(experiment_state, "\t"))

func get_quest_progress(quest_id: String) -> Dictionary:
	return experiment_state.get("quests", {}).get(quest_id, {}).duplicate(true)

func update_quest_progress(quest_id: String, objective_id: String, current: int, target: int) -> void:
	var quests: Dictionary = experiment_state.get("quests", {})
	var quest: Dictionary = quests.get(quest_id, {"status": "active", "objectives": {}})
	quest["objectives"][objective_id] = {"current": min(current, target), "target": target}
	quests[quest_id] = quest
	experiment_state["quests"] = quests
	save_experiment_state()
	quest_progress_changed.emit(quest_id, quest.duplicate(true))

func complete_quest(quest_id: String, rewards: Dictionary) -> void:
	var quests: Dictionary = experiment_state.get("quests", {})
	var quest: Dictionary = quests.get(quest_id, {"objectives": {}})
	if quest.get("status", "") == "complete":
		return
	quest["status"] = "complete"
	quests[quest_id] = quest
	experiment_state["quests"] = quests
	_award_unique("badges", rewards.get("badge", ""))
	_award_unique("stickers", rewards.get("sticker", ""))
	_award_unique("passport_stamps", rewards.get("passport_stamp", ""))
	_award_unique("completed_adventures", rewards.get("adventure", quest_id))
	var friendship: Dictionary = experiment_state.get("friendship_xp", {})
	var character_id: String = rewards.get("friendship_character", "")
	var xp := int(rewards.get("friendship_xp", 0))
	if not character_id.is_empty() and xp > 0:
		friendship[character_id] = int(friendship.get(character_id, 0)) + xp
		experiment_state["friendship_xp"] = friendship
		reward_awarded.emit("friendship_xp", character_id, xp)
	save_experiment_state()
	quest_completed.emit(quest_id)

func reset_experiment_state() -> void:
	experiment_state = DEFAULT_EXPERIMENT_STATE.duplicate(true)
	if FileAccess.file_exists(EXPERIMENT_SAVE_PATH):
		DirAccess.remove_absolute(EXPERIMENT_SAVE_PATH)

func _award_unique(collection: String, reward_id: String) -> void:
	if reward_id.is_empty():
		return
	var values: Array = experiment_state.get(collection, [])
	if reward_id not in values:
		values.append(reward_id)
		experiment_state[collection] = values
		reward_awarded.emit(collection, reward_id, 1)
