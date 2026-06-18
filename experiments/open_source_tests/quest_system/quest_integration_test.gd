extends Control

const OBJECTIVE_LABELS := {
	"collect_seashells": "🐚 Collect 5 Seashells",
	"visit_discovery_beach": "🏖 Visit Discovery Beach",
	"finish_wave_rider": "🏁 Complete Wave Rider Raceway",
}

func _ready() -> void:
	var world_state := get_node("/root/WorldState")
	$Adapter.progress_changed.connect(_refresh)
	$Adapter.quest_completed.connect(_on_quest_completed)
	world_state.reward_awarded.connect(_on_reward_awarded)
	await get_tree().process_frame
	_refresh($Adapter.get_progress())

func _advance(objective_id: String, amount: int = 1) -> void:
	$Adapter.advance_objective(objective_id, amount)

func _reset() -> void:
	$Adapter.reset_test_progress()
	$Reward.text = "Rewards route through WorldState only."
	_refresh($Adapter.get_progress())

func _refresh(progress: Dictionary) -> void:
	var lines: Array[String] = []
	for objective_id: String in OBJECTIVE_LABELS:
		var objective: Dictionary = progress.get(objective_id, {})
		var done := int(objective.get("current", 0)) >= int(objective.get("target", 1))
		lines.append("%s  %s  %d / %d" % ["✓" if done else "○", OBJECTIVE_LABELS[objective_id], objective.get("current", 0), objective.get("target", 0)])
	$QuestPanel/Objectives.text = "\n\n".join(lines)
	$QuestPanel/Status.text = "QUEST COMPLETE!" if progress.get("status", "") == "complete" else "Finn Tide is counting on us!"

func _on_quest_completed() -> void:
	$Reward.text = "★ Sea Turtle Rescue complete! WorldState awarded every reward."

func _on_reward_awarded(reward_type: String, reward_id: String, amount: int) -> void:
	$Reward.text = "WorldState event: %s • %s • %d" % [reward_type, reward_id, amount]
