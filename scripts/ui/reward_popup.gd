class_name RewardPopup
extends Control

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	SaveManager.mission_completed.connect(show_rewards)

func show_rewards(_mission_id: String, rewards: Dictionary) -> void:
	var lines: Array[String] = []
	var badge_id: String = rewards.get("badge", "")
	if not badge_id.is_empty():
		lines.append("🏅  %s BADGE" % badge_id.replace("_", " ").to_upper())
	var sticker := ContentCatalog.get_sticker(rewards.get("sticker", ""))
	if not sticker.is_empty():
		lines.append("%s  %s STICKER" % [sticker.get("icon", "★"), sticker.get("name", "New")])
	var world := ContentCatalog.get_world(rewards.get("passport_stamp", ""))
	if not world.is_empty():
		lines.append("📘  %s PASSPORT STAMP" % world.get("name", "World").to_upper())
	visible = true
	$Card/Rewards.text = "\n".join(lines)
	$Card.scale = Vector2(0.15, 0.15)
	$Card.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.7)
	tween.tween_property($Card, "modulate:a", 1.0, 0.15)
	tween.parallel().tween_property($Card, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(3.0)
	tween.tween_property($Card, "modulate:a", 0.0, 0.3)
	tween.tween_callback(hide)
