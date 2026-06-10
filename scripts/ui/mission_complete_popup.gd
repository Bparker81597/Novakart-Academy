class_name MissionCompletePopup
extends Control

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SaveManager.mission_completed.connect(show_mission_complete)

func show_mission_complete(mission_id: String, _rewards: Dictionary = {}) -> void:
	var mission := ContentCatalog.get_mission(mission_id)
	if mission.is_empty():
		return
	visible = true
	$Card/Name.text = mission.get("name", "Mission")
	$Confetti.restart()
	AudioManager.request_narration("mission_complete")
	$Card.scale = Vector2(0.15, 0.15)
	$Card.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($Card, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property($Card, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2.2)
	tween.tween_property($Card, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)
