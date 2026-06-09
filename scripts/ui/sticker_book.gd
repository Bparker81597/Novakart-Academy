class_name StickerBook
extends Control

const STICKER_CARD := preload("res://scenes/ui/StickerCard.tscn")

var current_category := "characters"

func _ready() -> void:
	_show_category(current_category)
	$Back.grab_focus()

func _show_category(category: String) -> void:
	current_category = category
	for child: Node in $StickerGrid.get_children():
		child.free()
	var category_stickers: Array[Dictionary] = []
	for sticker: Dictionary in ContentCatalog.get_all_stickers():
		if sticker.get("category", "") == category:
			category_stickers.append(sticker)
	for sticker: Dictionary in category_stickers:
		var card := STICKER_CARD.instantiate()
		card.configure(sticker, SaveManager.has_sticker(sticker.id))
		$StickerGrid.add_child(card)
	$Empty.visible = category_stickers.is_empty()
	$Case/CategoryTitle.text = "%s STICKERS" % category.to_upper()
	$Progress.text = "★  %d / %d STICKERS UNLOCKED" % [
		SaveManager.progress.get("collected_stickers", []).size(),
		ContentCatalog.stickers.size(),
	]

func _show_characters() -> void:
	_show_category("characters")

func _show_racing() -> void:
	_show_category("racing")

func _show_academy() -> void:
	_show_category("academy")

func _show_exploration() -> void:
	_show_category("exploration")

func _go_home() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/HubWorld.tscn")
