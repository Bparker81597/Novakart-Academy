class_name StickerCard
extends PanelContainer

func configure(sticker: Dictionary, unlocked: bool) -> void:
	var rarity_color := Color(sticker.get("rarity_color", "#62b7ff"))
	$Content/Icon.text = sticker.get("icon", "★") if unlocked else "?"
	$Content/Icon.modulate = rarity_color if unlocked else Color("#8b91a8")
	$Content/Name.text = sticker.get("name", "Mystery Sticker") if unlocked else "MYSTERY STICKER"
	$Content/Rarity.text = sticker.get("rarity", "common").to_upper()
	$Content/Hint.text = "UNLOCKED!" if unlocked else sticker.get("hint", "")
	$Content/Rarity.add_theme_color_override("font_color", rarity_color)
	modulate = Color.WHITE if unlocked else Color(0.72, 0.74, 0.8, 1)
	var style := StyleBoxFlat.new()
	style.bg_color = rarity_color.lightened(0.72) if unlocked else Color("#e2e4eb")
	style.border_color = rarity_color if unlocked else Color("#8990a6")
	style.set_border_width_all(7)
	style.set_corner_radius_all(28)
	style.shadow_color = Color(rarity_color.darkened(0.4), 0.35)
	style.shadow_size = 10 if unlocked else 3
	add_theme_stylebox_override("panel", style)
