class_name StickerUnlockPopup
extends Control

var sticker_queue: Array[String] = []
var showing := false

func show_stickers(sticker_ids: Array[String]) -> void:
	for sticker_id: String in sticker_ids:
		if sticker_id not in sticker_queue:
			sticker_queue.append(sticker_id)
	if not showing:
		_show_next()

func _show_next() -> void:
	if sticker_queue.is_empty():
		showing = false
		visible = false
		return
	showing = true
	visible = true
	var sticker_id: String = sticker_queue.pop_front()
	var sticker: Dictionary = ContentCatalog.get_sticker(sticker_id)
	var rarity_color := Color(sticker.get("rarity_color", "#62b7ff"))
	$Card/Icon.text = sticker.get("icon", "★")
	$Card/Icon.modulate = rarity_color
	$Card/Name.text = sticker.get("name", "New Sticker")
	$Card/Rarity.text = "%s STICKER" % sticker.get("rarity", "common").to_upper()
	$Card/Rarity.add_theme_color_override("font_color", rarity_color)
	var style: StyleBoxFlat = $Card/Backdrop.get_theme_stylebox("panel").duplicate()
	style.border_color = rarity_color
	$Card/Backdrop.add_theme_stylebox_override("panel", style)
	$Confetti.restart()
	AudioManager.play_sticker_unlock(sticker_id)
	$Card.scale = Vector2(0.12, 0.12)
	$Card.modulate.a = 0.0
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($Card, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property($Card, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(1.9)
	tween.tween_property($Card, "modulate:a", 0.0, 0.25)
	tween.tween_callback(_show_next)
