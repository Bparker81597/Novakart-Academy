class_name StickerBook
extends Control

func _ready() -> void:
	_build_sticker_grid()
	$Back.grab_focus()

func _build_sticker_grid() -> void:
	for sticker: Dictionary in ContentCatalog.get_all_stickers():
		var unlocked := SaveManager.has_sticker(sticker.id)
		var card := Button.new()
		card.custom_minimum_size = Vector2(250, 155)
		card.disabled = true
		card.text = "%s\n%s" % [
			sticker.icon if unlocked else "?",
			sticker.name if unlocked else sticker.hint,
		]
		card.add_theme_font_size_override("font_size", 25)
		$StickerGrid.add_child(card)
	$Progress.text = "★  %d / %d" % [
		SaveManager.progress.get("collected_stickers", []).size(),
		ContentCatalog.stickers.size(),
	]

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
