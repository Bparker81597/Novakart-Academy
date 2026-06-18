class_name SeaTurtleRescueQuest
extends Quest

const OBJECTIVE_TARGETS := {
	"collect_seashells": 5,
	"visit_discovery_beach": 1,
	"finish_wave_rider": 1,
}

@export var objectives: Dictionary = {
	"collect_seashells": 0,
	"visit_discovery_beach": 0,
	"finish_wave_rider": 0,
}

func update(args: Dictionary = {}) -> void:
	var objective_id: String = args.get("objective_id", "")
	if objective_id not in OBJECTIVE_TARGETS:
		return
	var amount := int(args.get("amount", 1))
	objectives[objective_id] = min(int(objectives.get(objective_id, 0)) + amount, int(OBJECTIVE_TARGETS[objective_id]))
	objective_completed = _all_objectives_complete()
	updated.emit()

func get_objective_progress(objective_id: String) -> Dictionary:
	return {
		"current": int(objectives.get(objective_id, 0)),
		"target": int(OBJECTIVE_TARGETS.get(objective_id, 0)),
	}

func serialize() -> Dictionary:
	return {
		"objective_completed": objective_completed,
		"objectives": objectives.duplicate(true),
	}

func deserialize(data: Dictionary) -> void:
	objectives.merge(data.get("objectives", {}), true)
	objective_completed = data.get("objective_completed", _all_objectives_complete())

func _all_objectives_complete() -> bool:
	for objective_id: String in OBJECTIVE_TARGETS:
		if int(objectives.get(objective_id, 0)) < int(OBJECTIVE_TARGETS[objective_id]):
			return false
	return true
