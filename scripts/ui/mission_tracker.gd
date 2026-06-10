class_name MissionTracker
extends PanelContainer

@export var mission_id := "lighthouse_hero"

func _ready() -> void:
	SaveManager.mission_progress_changed.connect(_on_mission_progress_changed)
	SaveManager.mission_completed.connect(_on_mission_completed)
	refresh()

func refresh() -> void:
	var mission := ContentCatalog.get_mission(mission_id)
	if mission.is_empty():
		visible = false
		return
	visible = true
	$Content/Title.text = "⚓  %s" % mission.get("name", "Mission")
	var lines: Array[String] = []
	for objective: Dictionary in mission.get("objectives", []):
		var current := SaveManager.get_mission_objective_progress(mission_id, objective.id)
		var target := int(objective.get("target", 1))
		var marker := "✓" if current >= target else "○"
		lines.append("%s %s %s  %d/%d" % [marker, objective.get("icon", "★"), objective.get("label", "Goal"), current, target])
	$Content/Objectives.text = "\n".join(lines)
	$Content/Complete.visible = SaveManager.is_mission_complete(mission_id)

func _on_mission_progress_changed(changed_mission_id: String) -> void:
	if changed_mission_id == mission_id:
		refresh()

func _on_mission_completed(completed_mission_id: String, _rewards: Dictionary) -> void:
	if completed_mission_id == mission_id:
		refresh()
